#include <stdio.h>
#include <math.h>
#include <windows.h>
#include "GL\glut.h"

enum Filter { F_NONE, F_SOBEL, F_HALFTONE, F_FLOYD };

GLuint texture[4];
GLubyte* newPics[4];

GLubyte* originalPic;
GLint original_width;
GLint original_height;

void writeArrayToFile(char questionNum, GLubyte* content, int size, BOOL isMonochrome)
{
	char filename[30];
	strcpy_s(filename, "assignment\\imgX.txt");
	filename[14] = questionNum;
	FILE* pFile;
	CreateDirectory("assignment", NULL);
	fopen_s(&pFile, filename, "wb");
	if (isMonochrome)
	{
		for (int i = 0; i < size; i++)
		{
			if (content[i] == 255)	fwrite("1", sizeof(char), 1, pFile);
			else					fwrite("0", sizeof(char), 1, pFile);

			if (i < size - 1)	fwrite(",", sizeof(char), 1, pFile);

		}
	}
	else
	{
		for (int i = 0; i < size; i++)
		{
			int value = content[i] / 16;
			char str[4];
			_itoa_s(value, str, 10);
			fwrite(str, sizeof(char)*strlen(str), 1, pFile);

			if (i < size - 1)	fwrite(",", sizeof(char), 1, pFile);
		}
	}
	fclose(pFile);
}

void sobel(GLubyte* pic)
{
	double threshold = 0.135 * 255;
	double m = (1.0 / 8);

	GLdouble sx[9] = { 
		m*-1, m * 0, m * 1,
		m*-2, m * 0, m * 2,
		m*-1, m * 0, m * 1
	};

	GLdouble sy[9] = { 
		m * 1, m * 2, m * 1,
		m * 0, m * 0, m * 0,
		m* -1, m *-2, m *-1
	};

	GLdouble* tmp_sobel = new GLdouble[original_width*original_height];

	for (int i = 0; i < original_height; i++)
	{
		for (int j = 0; j < original_width; j++)
		{
			tmp_sobel[i * original_width + j] = 0;
			int horizontal_weight = 0;
			int vertical_weight = 0;

			//going through the 9 neighbors 
			for (int w = i - 1; w <= i + 1; w++){
				for (int h = j - 1; h <= j + 1; h++){
					//if inside pic borders
					if (w >= 0 && h >= 0 && w < original_height && h < original_width){
						//update pixel with neighbor multiplied 

						horizontal_weight += originalPic[w * original_width + h] * sx[(w - i + 1) * 3 + (h - j + 1)];
						vertical_weight   += originalPic[w * original_width + h] * sy[(w - i + 1) * 3 + (h - j + 1)];
					}
				}
			}
			tmp_sobel[i * original_width + j] = abs(horizontal_weight) + abs(vertical_weight);
		}
	}
	for (int i = 0; i < original_width*original_height; i++){
		pic[i] = (tmp_sobel[i] < threshold) ? 0 : 255;
	}
}

void halftone(GLubyte* pic)
{
	memset(pic, 255, original_height*original_width * 4 * sizeof(GLubyte));

	for (int i = 0; i<original_height; i++)
	{
		for (int j = 0; j<original_width; j++)
		{			
			int k=j*2;
			int l=i*2;

			if(originalPic[i+j*original_width]<=255*1/5.0)
			pic[l+k*original_width*2]=0;

			if(originalPic[i+j*original_width]<=255*2/5.0)
			pic[l+1+k*original_width*2]=0;

			if(originalPic[i+j*original_width]<=255*3/5.0)
			pic[l+1+(k+1)*original_width*2]=0;
			if(originalPic[i+j*original_width]<=255*4/5.0)
			pic[l+(k+1)*original_width*2]=0;

		}
	}
}

void floyd(GLubyte* pic)
{
	int numOfColors = 16;

	GLdouble* tmp = new GLdouble[original_width*original_height];

	for (int i = 0; i < original_width*original_height; i++) {
		tmp[i] = (GLdouble)originalPic[i];
	}

	GLdouble a = 7.0 / 16.0;
	GLdouble b = 3.0 / 16.0;
	GLdouble c = 5.0 / 16.0;
	GLdouble d = 1.0 / 16.0;

	for (int i = 0; i < original_height; i++) {
		for (int j = 0; j < original_width; j++) {
			tmp[i*original_width + j] -= (((int)tmp[i*original_width + j]) % (256/numOfColors));
			
			double e = originalPic[i*original_width + j] - tmp[i*original_width + j];

			if (j+1 < original_width)				tmp[i*original_width + j + 1]		+= (a*e);
			if (i + 1 < original_height)
			{
				if		(j - 1 < original_width)		tmp[(i + 1)*original_width + j - 1] += (b*e);
				else if (j < original_width)			tmp[(i + 1)*original_width + j]		+= (c*e);
				else if (j + 1 < original_width)		tmp[(i + 1)*original_width + j + 1] += (d*e);		
			}		
		}
	}
	
	for (int i = 0; i < original_width; i++) {
		for (int j = 0; j < original_height; j++) {
			pic[i*original_width + j] = (GLubyte)tmp[i*original_width + j];
		}
	}

	delete[] tmp;
	
}

void details(GLubyte* pic)
{
	GLfloat *tmp1 = new GLfloat[original_height*original_width];
	GLfloat log[9] = { 0.4, 0.8, 0.4, 0.8, -3.82, 0.8, 0.4, 0.8, 0.4 };
	int sum;

	for (int i = 0; i<original_width; i++)
	{
		for (int j = 0; j<original_height; j++)
		{
			sum = 0;
			tmp1[i + j*original_width] = 0;
			for (int k = i - 1; k <= i + 1; k++)
				for (int l = j - 1; l <= j + 1; l++)
					if (l >= 0 && k >= 0 && l<original_height && k<original_width)
					{
						tmp1[i + j*original_width] += originalPic[k + l*original_width] * log[i - k + 1 + 3 * (j - l + 1)];
					}
		}
	}
	memset(pic, 0, original_height*original_width*sizeof(GLubyte));

	printf("\n***********details*****************\n");
	for (int i = 0; i<original_width * 6 + 500; i++)
		printf("%0.2f  ", tmp1[i]);

	printf("\n****************************\n");

	for (int i = 1; i<original_width; i++)
	{
		for (int j = 0; j<original_height; j++)
		{
			if (tmp1[i + j*original_width] * tmp1[i - 1 + j*original_width]<-650)
				pic[i + j*original_width] = 255;
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

	delete tmp1;
}

void applyFilterToTexture(Filter filter, void(*function)(GLubyte*), int width, int height)
{
	if (function != NULL)	function(newPics[filter]);

	glGenTextures(1, &texture[filter]);  //generate place for new texture
	glBindTexture(GL_TEXTURE_2D, texture[filter]); // initialize first texure 

	//texture properties
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

	//build texture
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, newPics[filter]);

}

void init(const char* filename)
{
	FILE* f1;
	int rd;
	GLubyte header[54], colorTable[1024];
	glEnable(GL_TEXTURE_2D);
	glOrtho(-1.0, 1.0, -1.0, 1.0, 2.0, -2.0);
	glClearColor(0, 0, 0, 0);

	fopen_s(&f1, filename, "rb");

	/*************************/
	//image header reading
	fread(header, 54, 1, f1);
	if (header[0] != 'B' || header[1] != 'M')		exit(1);  //not a BMP file

	original_width = *(int*)(header + 18);
	original_height = *(int*)(header + 22);
	printf("\nlena %d %d %d \n", original_width, original_height, original_width*original_height);

	/**********************************/

	originalPic			= new GLubyte[original_width*original_height];
	newPics[F_NONE] = originalPic;
	newPics[F_SOBEL]	= new GLubyte[original_width*original_height];
	newPics[F_HALFTONE] = new GLubyte[original_height*original_width * 4];
	newPics[F_FLOYD]	= new GLubyte[original_width*original_height];

	rd = fread(colorTable, 1, 1024, f1); //read color table
	rd = fread(originalPic, 1, original_width*original_height, f1); //read image

	fclose(f1);


	applyFilterToTexture(F_NONE,		NULL,		original_width, original_height);
	applyFilterToTexture(F_SOBEL,		sobel,		original_width, original_height);
	applyFilterToTexture(F_HALFTONE,	halftone,	original_width*2, original_height*2);
	applyFilterToTexture(F_FLOYD,		floyd,		original_width, original_height);

	writeArrayToFile('4', newPics[F_SOBEL],		original_width*original_height,		TRUE);
	writeArrayToFile('5', newPics[F_HALFTONE],	original_width*original_height*4,	TRUE);
	writeArrayToFile('6', newPics[F_FLOYD],		original_width*original_height,		FALSE);
}

void paintQuadWithTexture(GLint x, GLint y, GLsizei width, GLsizei height, GLuint textureKey)
{
	glViewport(x, y, width, height);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glBindTexture(GL_TEXTURE_2D, textureKey); //using first texture

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
}

void mydisplay(void){

	glClear(GL_COLOR_BUFFER_BIT);

	glColor3f(1.0f, 1.0f, 1.0f);

	paintQuadWithTexture(0,	  256, 256, 256, texture[F_NONE]);
	paintQuadWithTexture(256, 256, 256, 256, texture[F_SOBEL]);
	paintQuadWithTexture(0,	  0,   256, 256, texture[F_HALFTONE]);
	paintQuadWithTexture(256, 0,   256, 256, texture[F_FLOYD]);

	glBindTexture(GL_TEXTURE_2D, 0);
	glFlush();
}

int main(int  argc, char** argv)
{
	if (argc < 2){
		printf("Please specify a filename. \n Exiting..");

		exit(1);
	}
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
	glutInitWindowSize(512, 512);
	glutCreateWindow("Assignment1");

	init(argv[1]);
	glutDisplayFunc(mydisplay);
	glutMainLoop();


	//delete originalPic;	//original
	delete[] newPics;
}