#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
//#include <gcrypt.h> /* sha1 / crc32 */
#include <fcntl.h>


#include "swpack.h"

#define VERSION "1.3d"

void clear (FILE *fp)
{
	char buf[255];
	while (fgets (buf, 255, fp) != NULL && feof (fp)) {
		/* puts (buf); */
	}
}

int main(int argc, char* argv[])
{ 
   FILE*          file;
   int            i, data_len;
   unsigned char* buffer;
   struct         stat buf;

   bool doInfo = false;
   bool doVerify = false;
   bool doXML = false;
   bool doXMLDetail = false;
   bool doExtract = false;
   bool doCreate = false;
   
   if (argc == 3 && strlen(argv[1]) == 1 && !strncmp(argv[1], "i", 1))
	   doInfo = true;
   else if (argc == 3 && strlen(argv[1]) == 1 && !strncmp(argv[1], "v", 1))
	   doVerify = true;
   else if (argc == 3 && strlen(argv[1]) == 1 && !strncmp(argv[1], "x", 1))
	   doXML = true;
   else if (argc == 3 && strlen(argv[1]) == 2 && !strncmp(argv[1], "xx", 2))
	   doXMLDetail = true;
   else if (argc == 3 && strlen(argv[1]) == 1 && !strncmp(argv[1], "e", 1))
	   doExtract = true;
   else if (argc == 3 && strlen(argv[1]) == 1 && !strncmp(argv[1], "c", 1))
   	   doCreate = true;
   else
   {
	   printf("Version: %s %s\n", argv[0], VERSION);
	   printf("Usage:\n");
	   printf("For image information:\n");
	   printf("  %s i FILENAME       Info as TXT\n", argv[0]);
	   printf("  %s x FILENAME       Info as XML (basic)\n", argv[0]);
	   printf("  %s xx FILENAME      Info as TXT (detailed)\n", argv[0]);
	   printf("For image verification:\n");
	   printf("  %s v FILENAME       \n", argv[0]);
	   printf("For image extraction:\n");
	   printf("  %s e FILENAME        \n", argv[0]);
	   printf("For image generation:\n");
	   printf("  %s c FILENAME        \n", argv[0]);
	   exit(10);
   }
   
   if(doInfo || doVerify || doXML || doXMLDetail || doExtract)
   {
	   //////////////////////////////////
	   if (stat(argv[2], &buf) < 0)
	   {
			fprintf(stderr, "Cannot open(stat) %s", argv[2]);
			return -2;
	   }
	   data_len = buf.st_size;

	   file = fopen(argv[2], "r");

	   if (file == NULL)
	   {
		  fprintf(stderr, "Unable to open %s\n", argv[1]);
		  return -3;
	   }

	   buffer = (unsigned char*) malloc(data_len);

	   if (buffer == NULL)
	   {
		  fprintf(stderr, "Unable to get mem %d\n", data_len);
		  return -4;
	   }

	   i = fread( buffer, 1, data_len, file);

	   //////////////////////////////////

	   SwPack * swpack = new SwPack(buffer, i);

		swpack->parse();

		if(doInfo)
			swpack->print();
		else if(doVerify)
		{
			if (swpack->verify())
				printf("Image is correct\n");
			else
				printf("Image is NOT correct\n");
		}
		else if(doXML || doXMLDetail)
		{
			printf("<MARUSWUP version=\"1.0\">\n");
			swpack->printXML(doXMLDetail);
			printf("</MARUSWUP>\n");
		} else if(doExtract)
			swpack->extract();

		/* act of solidarity ;) */
		free( buffer );
		fclose(file);
   }
   else if(doCreate)
   {
	   //////////////////////////////////

	   /*
	   - create list of partitions
	   - create swpack
	   - swpack set boxtype
	   - swpack append partition (address, filename)
	   - swpack create update image
	   */

	   char outputName[1024];
	   strcpy(outputName, argv[2]);
	   unsigned int inputBufferLength = 255;
	   char inputBuffer[inputBufferLength + 1];
	   char partitionName[inputBufferLength + 1];
	   int productCode = 0;
	   int flashOffset = -1;
	   int nand = 0;
	   int blocksize = 0;

	   SwPack * swpack = new SwPack();

	   printf("Choose ProductCode\n");
	   printf("1: 0x11321000 - Kathrein UFS-922\n");
	   printf("2: 0x11301003 - Kathrein UFS-912\n");
	   printf(":> ");
	   scanf("%d", &productCode);

	   switch(productCode)
	   {
	   case 1: productCode = 0x11321000; break;
	   case 2: default: productCode = 0x11301003; break;
	   }

	   swpack->setProductCode(productCode);

	   printf("Enter partitions. \"FLASHOFFSET, NAND, FILENAME;\"\n");
	   printf("Finish list with \";\"\n");
	   printf("Example: \n");
	   printf("\t0x004E0000, 0, 922.cramfs\n");
	   printf("\t0x00040000, 0, uImage.922.105\n");
	   printf("\t0x002A0000, 0, root.922.105.cramfs\n");
	   printf(";\n");

	   fflush (stdin);
	   clear (stdin);

	   while(1)
	   {
		   printf(":> ");
		   flashOffset = -1;
		   scanf("0x%X, ", &flashOffset);
		   if(flashOffset == -1)
			   break;
		   scanf("%d, ", &nand);
		   if(nand != 0 && nand != 1 && nand != 2)
			   break;
		   scanf("%s", inputBuffer);
		   printf("\tflashOffset: %d, inputBuffer: %s\n", flashOffset, inputBuffer);

		   fflush (stdin);
		   clear (stdin);

		   {
			   stat(inputBuffer, &buf);
		   	   data_len = buf.st_size;

		   	   file = fopen(inputBuffer, "r");
		   	   if (file == NULL)
		   	   {
		   		  fprintf(stderr, "Unable to open %s\n", inputBuffer);
		   		  return -3;
		   	   }

		   	   buffer = (unsigned char*) malloc(data_len);

		   	   if (buffer == NULL)
		   	   {
		   		  fprintf(stderr, "Unable to get mem %d\n", data_len);
		   		  return -4;
		   	   }

		   	   i = fread( buffer, 1, data_len, file);
		   	   fclose(file);

		   	   if(nand == 1) {
		   		sprintf(partitionName, "/2/O3/");
		   		strcat(partitionName, inputBuffer);
		   	   }
		   	   else if(nand == 2) {
		   		blocksize = data_len;
		   		if(blocksize % (1<<16) != 0)
		   		{
		   			blocksize = (blocksize >> 16) + 1;
				  //blocksize += (1<<16) - (blocksize % (1<<16));
		   		}
		   		else
		   			blocksize = blocksize >> 16;

		   		printf("BS: %d\n", blocksize);

		   		sprintf(partitionName, "/%d/O5/", blocksize);
				strcat(partitionName, inputBuffer);
			   }
		   	   else
		   		strcpy(partitionName, inputBuffer);

		   	   swpack->appendPartition(flashOffset, partitionName,          (unsigned char*)buffer		   , i);

		   	   free(buffer);
		   }
	   }

		swpack->printXML(true);

		data_len = swpack->createImage(&buffer);

		file = fopen(outputName, "wb");
		if (file == NULL)
		{
		  fprintf(stderr, "Unable to open %s\n", outputName);
		  return -3;
		}

		if (buffer == NULL)
		{
		  fprintf(stderr, "Unable to get mem %d\n", data_len);
		  return -4;
		}

		i = fwrite( buffer, 1, data_len, file);

		fclose(file);
#if 0
	   SwPack * swpack = new SwPack();
	   swpack->setProductCode(0x11321000);

	   char * part1 = strdup("922.cramfs");
	   char * part2 = strdup("uImage.922.105");
	   char * part3 = strdup("root.922.105.cramfs");

	   //////////////
	   stat(part1, &buf);
	   data_len = buf.st_size;

	   file = fopen(part1, "r");
	   if (file == NULL)
	   {
		  fprintf(stderr, "Unable to open %s\n", part1);
		  return -3;
	   }

	   buffer = (unsigned char*) malloc(data_len);

	   if (buffer == NULL)
	   {
		  fprintf(stderr, "Unable to get mem %d\n", data_len);
		  return -4;
	   }

	   i = fread( buffer, 1, data_len, file);
	   fclose(file);

	   swpack->appendPartition(0x004E0000, part1,          (unsigned char*)buffer		   , i);

	   free(buffer);

	   //////////////
	   stat(part2, &buf);
	   data_len = buf.st_size;

	   file = fopen(part2, "r");
	   if (file == NULL)
	   {
		  fprintf(stderr, "Unable to open %s\n", part2);
		  return -3;
	   }

	   buffer = (unsigned char*) malloc(data_len);

	   if (buffer == NULL)
	   {
		  fprintf(stderr, "Unable to get mem %d\n", data_len);
		  return -4;
	   }

	   i = fread( buffer, 1, data_len, file);
	   fclose(file);

	   swpack->appendPartition(0x00040000, part2, (unsigned char*)buffer		   , i);

	   free(buffer);

	   //////////////
	   stat(part3, &buf);
	   data_len = buf.st_size;

	   file = fopen(part3, "r");
	   if (file == NULL)
	   {
		  fprintf(stderr, "Unable to open %s\n", part3);
		  return -3;
	   }

	   buffer = (unsigned char*) malloc(data_len);

	   if (buffer == NULL)
	   {
		  fprintf(stderr, "Unable to get mem %d\n", data_len);
		  return -4;
	   }

	   i = fread( buffer, 1, data_len, file);
	   fclose(file);

	   swpack->appendPartition(0x002A0000, part3,      (unsigned char*)buffer		   , i);

	   free(buffer);

	   /////////////

	   swpack->printXML(true);

	   data_len = swpack->createImage(&buffer);

	   file = fopen("update.img", "wb");
	   	   if (file == NULL)
	   	   {
	   		  fprintf(stderr, "Unable to open %s\n", part1);
	   		  return -3;
	   	   }

	   	   if (buffer == NULL)
	   	   {
	   		  fprintf(stderr, "Unable to get mem %d\n", data_len);
	   		  return -4;
	   	   }

	   	   for(int j = 0; j < 20; j++)
	   		   printf("%02X ", *(buffer+j));
	   	printf("\n");

	   	   i = fwrite( buffer, 1, data_len, file);
	   	   fclose(file);
#endif
   }
   return 0;
}

