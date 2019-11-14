#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define MAXSTRLENGTH 100
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

int PNGtoCOE(char *PNGfilename,char *COEfilename) 
{
	int width, height, nrChannels;
	unsigned char *data = stbi_load(PNGfilename, &width, &height, &nrChannels, 0);
	printf("%d", nrChannels);
	if (data){
		FILE *outfp=fopen(COEfilename,"w");
		fprintf(outfp,"memory_initialization_radix=16;\nmemory_initialization_vector =\n");
		
		printf("图片尺寸%d*%d\n", width, height);
		
		int i, j;
		unsigned char r, g, b, a;
		for (i = 0; i < height; i++)
			for (j = 0; j < width; j++){
				r = data[i*width*4 + j*4];
				g = data[i*width*4 + j*4 + 1];
				b = data[i*width*4 + j*4 + 2];
				a = data[i*width*4 + j*4 + 3];
				fprintf(outfp,"%x%x%x%x,\n",(int)(a/256.0*16), (int)(b/256.0*16), (int)(g/256.0*16), (int)(r/256.0*16)); 
			}
		fclose(outfp);
		return 0;
			
	}
	else{
		printf("\n文件不存在\n");
		return 1;
	}
} 

int main()
{
	char PNGfilename[MAXSTRLENGTH],COEfilename[MAXSTRLENGTH];
	printf("请输入PNG图片文件名（需为24位PNG图片，无需加扩展名）\n");
	scanf("%s",PNGfilename);
	strcpy(COEfilename,PNGfilename);
	strcat(PNGfilename,".png");
	strcat(COEfilename,".coe");
	if(!PNGtoCOE(PNGfilename,COEfilename)) 
		printf("已生成%s\n",COEfilename);
	system("pause");
}
