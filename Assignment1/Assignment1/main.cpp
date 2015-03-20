#include <stdio.h>
#include <math.h>
#include <windows.h>
#include "GL\glut.h"

GLuint texture[4];
GLuint bitTex;
//first image
GLubyte *pic;
GLint width;
GLint height;
//second image
GLubyte *pic1;
GLint width1;
GLint height1;
GLubyte *newpic, *newpic1, *newpic2, *newpic3;
GLubyte *tmp;
GLubyte *tmp2;

void halftone(GLubyte *tmp)
{

	memset(tmp, 255, height1*width1 * 9 * sizeof(GLubyte));
	for (int i = 0; i<width1; i++)
	{

		for (int j = 0; j<height1; j++)
		{
			/*
			int k=j*2;
			int l=i*2;



			if(pic1[i+j*width1]<=255*1/5.0)
			tmp[l+k*width1*2]=0;

			if(pic1[i+j*width1]<=255*2/5.0)
			tmp[l+1+k*width1*2]=0;

			if(pic1[i+j*width1]<=255*3/5.0)
			tmp[l+1+(k+1)*width1*2]=0;
			if(pic1[i+j*width1]<=255*4/5.0)
			tmp[l+(k+1)*width1*2]=0;
			*/




			//newpic[i+j*width1]=255;

			int k = j * 3 + 1;
			int l = i * 3 + 1;

			if (pic1[i + j*width1] <= 255 * 9 / 10.0)
				tmp[l + (k - 1)*width1 * 3] = 0;

			if (pic1[i + j*width1] <= 255 * 8 / 10.0)
				tmp[l - 1 + (k + 1)*width1 * 3] = 0;

			if (pic1[i + j*width1] <= 255 * 7 / 10.0)
				tmp[l + 1 + (k + 1)*width1 * 3] = 0;

			if (pic1[i + j*width1] <= 255 * 6 / 10.0)
				tmp[l + 1 + (k + 1)*width1 * 3] = 0;

			if (pic1[i + j*width1] <= 255 * 5 / 10.0)
				tmp[l - 1 + k*width1 * 3] = 0;

			if (pic1[i + j*width1] <= 255 * 4 / 10.0)
				tmp[l - 1 + (k + 1)*width1 * 3] = 0;

			if (pic1[i + j*width1] <= 255 * 3 / 10.0)
				tmp[l + (k - 1)*width1 * 3] = 0;

			if (pic1[i + j*width1] <= 255 * 2 / 10.0)
				tmp[l + 1 + k*width1 * 3] = 0;

			if (pic1[i + j*width1] <= 255 / 10.0)
				tmp[l + k*width1 * 3] = 0;

		}
	}

	//gluScaleImage(GL_LUMINANCE,width1*3,height1*3,GL_UNSIGNED_BYTE,tmp,width1,height1,GL_UNSIGNED_BYTE,newpic);
	/*
	for(int i=0;i<width1*2;i++)
	{
	for(int j=0;j<height1;j++)
	{
	if(newpic[i+j*width1]>48)
	newpic[i+j*width1]=255;
	else newpic[i+j*width1]=0;
	}
	}*/

	//gluScaleImage(GL_LUMINANCE,width1*2,height1*2,GL_UNSIGNED_BYTE,newpic1,width1,height1,GL_UNSIGNED_BYTE,newpic);
	/*
	for(int i=0;i<width1*2;i++)
	{
	for(int j=0;j<height1;j++)
	{
	if(newpic[i+j*width1]>64)
	newpic[i+j*width1]=255;
	else newpic[i+j*width1]=0;
	}
	}
	*/

}

void details()
{
	GLfloat *tmp1;
	GLfloat log[9] = { 0.4, 0.8, 0.4, 0.8, -3.82, 0.8, 0.4, 0.8, 0.4 };
	int sum;
	tmp1 = new GLfloat[height1*width1];

	for (int i = 0; i<width1; i++)
	{
		for (int j = 0; j<height1; j++)
		{
			sum = 0;
			tmp1[i + j*width1] = 0;
			for (int k = i - 1; k <= i + 1; k++)
				for (int l = j - 1; l <= j + 1; l++)
					if (l >= 0 && k >= 0 && l<height1 && k<width1)
					{
						tmp1[i + j*width1] += pic1[k + l*width1] * log[i - k + 1 + 3 * (j - l + 1)];
					}
		}
	}
	memset(newpic2, 0, height1*width1*sizeof(GLubyte));

	printf("\n***********details*****************\n");
	for (int i = 0; i<width1 * 6 + 500; i++)
		printf("%0.2f  ", tmp1[i]);

	printf("\n****************************\n");

	for (int i = 1; i<width1; i++)
	{
		for (int j = 0; j<height1; j++)
		{
			if (tmp1[i + j*width1] * tmp1[i - 1 + j*width1]<-650)
				newpic2[i + j*width1] = 255;
		}
	}
	/*
	for(int i=0;i<width1;i++)
	{
	for(int j=1;j<height1;j++)
	{
	if(tmp1[i+j*width1]*tmp1[i+(j-1)*width1]<0)
	newpic2[i+j*width1]=255;

	}
	}
	*/

	delete tmp;
}

void dithering()
{
	float *tmp1;
	int colorNum = 16;
	int sum;
	tmp1 = new float[height1*width1];
	memset(tmp1, 0, sizeof(float)*height1*width1);
	for (int i = 0; i<width1; i++)
	{
		for (int j = 0; j<height1; j++)
		{
			sum = 0;
			tmp1[i + j*width1] += pic1[i + j*width1];
			while (tmp1[i + j*width1] >= 256 / colorNum && sum<255)
			{
				sum += 256 / colorNum;
				tmp1[i + j*width1] -= 256 / colorNum;
			}
			if (sum<255)
				newpic3[i + j*width1] = sum;
			else newpic3[i + j*width1] = 240;
			if (i + j*width1 + 1<width1*height1)
				tmp1[i + j*width1 + 1] += tmp1[i + j*width1] * 7.0 / 16.0;
			if (j<height1 - 1)
			{
				if (i<width1 - 1)
					tmp1[i + (1 + j)*width1 + 1] += tmp1[i + j*width1] * 1 / 16.0;
				tmp1[i + (1 + j)*width1] += tmp1[i + j*width1] * 5.0 / 16.0;
				tmp1[i + (1 + j)*width1 - 1] += tmp1[i + j*width1] * 3.0 / 16.0;
			}
		}
	}

	printf("\n****************************\n");
	for (int i = 0; i<264; i++)
		printf("%d  ", newpic3[i]);
	printf("\n****************************\n");

	delete tmp1;
}


void init()
{
	FILE *f, *f1;
	int picSize, picSize1;
	int rd;
	GLubyte header[54], colorTable[1024];
	//GLubyte *newpic;
	glEnable(GL_TEXTURE_2D);
	glOrtho(-1.0, 1.0, -1.0, 1.0, 2.0, -2.0);
	//gluPerspective(20,1,0.5,8);
	//glTranslatef(0,0,-4);

	glClearColor(0, 0, 0, 0);
	//glEnable(GL_DEPTH_TEST);
	//glDepthFunc(GL_LEQUAL);
	//	glDisable(GL_BLEND);
	f = fopen("coloseum3.bmp", "rb");

	/*************************/
	//first image header reading
	fread(header, 54, 1, f);
	if (header[0] != 'B' || header[1] != 'M')
		exit(1);  //not a BMP file
	for (int i = 0; i<54; i++)
		printf("%x  ", header[i]);


	picSize = (*(int*)(header + 2) - 54);
	width = *(int*)(header + 18);
	height = *(int*)(header + 22);
	printf("\n%d %d %d %d \n", picSize, width, height, width*height * 3);

	/**********************************/

	pic = new GLubyte[picSize];
	rd = fread(pic, 1, picSize, f); //read image
	fclose(f);
	/*
	for(int i = 0; i < height*width; i += 3)
	{
	unsigned char tmp = pic[i];
	pic[i] = pic[i+2];
	pic[i+2] = tmp;
	}
	*/
	printf("*****  %d *******\n", rd);

	f1 = fopen("lena256.bmp", "rb");
	//f1=fopen("coloseum21.bmp","rb");

	/*************************/
	//second image header reading
	fread(header, 54, 1, f1);
	if (header[0] != 'B' || header[1] != 'M')
		exit(1);  //not a BMP file
	for (int i = 0; i<54; i++)
		printf("%x  ", header[i]);


	picSize1 = (*(int*)(header + 2) - 54);
	width1 = *(int*)(header + 18);
	height1 = *(int*)(header + 22);
	printf("\nlena %d %d %d %d \n", picSize1, width1, height1, width1*height1);

	/**********************************/

	pic1 = new GLubyte[width1*height1];
	newpic = new GLubyte[width1*height1];
	newpic2 = new GLubyte[width1*height1];
	newpic3 = new GLubyte[width1*height1];
	newpic1 = new GLubyte[width1*height1 * 4];
	tmp = new GLubyte[height1*width1 * 9];
	tmp2 = new GLubyte[height1*width1 * 4];
	printf("*****  color table *******\n", rd);
	rd = fread(colorTable, 1, 1024, f1); //read color table
	for (int i = 0; i<256 * 4; i++)
		if (i % 4 == 0)
			printf("%x  ", colorTable[i]);
	printf("\n");

	rd = fread(pic1, 1, width1*height1, f1); //read image

	printf("*****  %d *******\n", rd);

	fclose(f1);


	printf("texture\n");

	//************ first image **************************
	//glPixelStorei(GL_UNPACK_ALIGNMENT,1);
	glGenTextures(1, &texture[0]);  //generate place for new texture
	glBindTexture(GL_TEXTURE_2D, texture[0]); // initialize first texure 

	//texture properties
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

	//build texture
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width1, height1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, pic1);


	//************ second image **************************	



	halftone(tmp);

	glGenTextures(1, &texture[1]);
	glBindTexture(GL_TEXTURE_2D, texture[1]);


	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

	printf("\n***********halfton*****************\n");
	for (int i = 0; i<width1 * 6; i++)
		if (tmp[i] == 255)
			printf("%d  ", i);
		else printf("bla  ");
		printf("\n****************************\n");

		gluScaleImage(GL_LUMINANCE, width1 * 3, height1 * 3, GL_UNSIGNED_BYTE, tmp, width1 * 2, height1 * 2, GL_UNSIGNED_BYTE, tmp2);
		for (int i = 0; i<width1 * 2; i++)
			for (int j = 0; j<height1 * 2; j++)
				if (tmp2[i + j*width1 * 2]>178)
					tmp2[i + j*width1 * 2] = 255;
				else tmp2[i + j*width1 * 2] = 0;
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width1 * 2, height1 * 2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, tmp2);

				//************ third image **************************	
				details();
				glGenTextures(1, &texture[2]);
				glBindTexture(GL_TEXTURE_2D, texture[2]);


				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);


				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width1, height1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, newpic2);


				//************ forth image **************************	

				dithering();
				glGenTextures(1, &texture[3]);
				glBindTexture(GL_TEXTURE_2D, texture[3]);


				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);


				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width1, height1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, newpic3);
}



void mydisplay(void){

	glClear(GL_COLOR_BUFFER_BIT);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glBindTexture(GL_TEXTURE_2D, texture[1]); //using first texture
	glViewport(0, 0, 256, 256);


	glColor3f(1.0f, 1.0f, 1.0f);



	//glShadeModel(GL_FLAT);
	glBegin(GL_QUADS);
	glTexCoord2f(0, 0); //adapt texture to shape
	glVertex3f(-1.0, -1.0f, 1.0);

	glTexCoord2f(1, 0);  //adapt texture to shape
	glVertex3f(1.0, -1.0f, 1.0);

	glTexCoord2f(1, 1);//adapt texture to shape
	glVertex3f(1.0, 1.0f, 1.0);

	glTexCoord2f(0, 1);//adapt texture to shape
	glVertex3f(-1.0, 1.0f, 1.0);
	glEnd();
	glBindTexture(GL_TEXTURE_2D, 0);


	glViewport(256, 256, 256, 256);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glBindTexture(GL_TEXTURE_2D, texture[2]); //using first texture
	//glScalef(0.5,0.5,1);
	glBegin(GL_QUADS);
	glTexCoord2f(0, 0);
	glVertex3f(-1.0, -1.0f, -1.0);

	glTexCoord2f(1, 0);
	glVertex3f(1.0, -1.0f, -1.0);

	glTexCoord2f(1, 1);
	glVertex3f(1.0, 1.0f, -1.0);

	glTexCoord2f(0, 1);
	glVertex3f(-1.0, 1.0f, -1.0);
	glEnd();
	//glBindTexture(GL_TEXTURE_2D, 0);

	glViewport(0, 256, 256, 256);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glBindTexture(GL_TEXTURE_2D, texture[0]); //using first texture
	//glScalef(0.5,0.5,1);
	glBegin(GL_QUADS);
	glTexCoord2f(0, 0);
	glVertex3f(-1.0, -1.0f, -1.0);

	glTexCoord2f(1, 0);
	glVertex3f(1.0, -1.0f, -1.0);

	glTexCoord2f(1, 1);
	glVertex3f(1.0, 1.0f, -1.0);

	glTexCoord2f(0, 1);
	glVertex3f(-1.0, 1.0f, -1.0);
	glEnd();

	glViewport(256, 0, 256, 256);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glBindTexture(GL_TEXTURE_2D, texture[3]); //using first texture
	//glScalef(0.5,0.5,1);
	glBegin(GL_QUADS);
	glTexCoord2f(0, 0);
	glVertex3f(-1.0, -1.0f, -1.0);

	glTexCoord2f(1, 0);
	glVertex3f(1.0, -1.0f, -1.0);

	glTexCoord2f(1, 1);
	glVertex3f(1.0, 1.0f, -1.0);

	glTexCoord2f(0, 1);
	glVertex3f(-1.0, 1.0f, -1.0);
	glEnd();


	glBindTexture(GL_TEXTURE_2D, 0);


	glFlush();
}


int main(int  argc, char** argv)
{

	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
	glutInitWindowSize(512, 512);
	glutCreateWindow("Simple");
	init();
	// glutReshapeFunc(myReshape);
	glutDisplayFunc(mydisplay);
	//glutIdleFunc(mydisplay);
	// printf("pi = %f",3.14);
	//glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);
	glutMainLoop();

	delete newpic1;

	delete newpic;
	delete newpic2;
	delete newpic3;

	delete(pic);
	delete(pic1);
	delete(tmp);
}