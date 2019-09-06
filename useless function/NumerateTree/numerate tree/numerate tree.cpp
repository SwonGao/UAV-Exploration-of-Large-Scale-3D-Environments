// numerate tree.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "stdlib.h"
#include "string"
#include "iostream"

using namespace std;

struct node{
	node* parent;
	int x;
	int y;
	int depth;
	int coin;
	node* child1;
	node* child2;
	node* child3;
	node* child4;
};

//==============================global variables
#define MAXCOIN 304
#define MAXDEPTH 3750
#define M 25
#define N 15

int coinmap[N][M] = {0};
char direction[N][M][4] = {};
node bestnode;

//===============================子函数================================
node* Createnode(node* head,int x,int y)
{	
	node* a;
	a = (node*)malloc(sizeof(node));
	a->parent = head;
	a->x = x; a->y = y;
	if(head)
	{
	a->depth = head->depth + 1;
		if(coinmap[a->x][a->y] == 1)
		{
			coinmap[a->x][a->y] = 0;
			a->coin = 1;
		}
		else a->coin = 0;
	}
	else
	{
		a->depth = 1;
		if(coinmap[a->x][a->y] == 1)
		{
			coinmap[a->x][a->y] = 0;
			a->coin++;
		}
	}
	if(a->depth > MAXDEPTH){
		free(a);
		return NULL;
	}
	a->child1 = NULL;
	a->child2 = NULL;
	a->child3 = NULL;
	a->child4 = NULL;
	return a;
}

void Deletenodes(node* head)
{
	if(head->child1)
		Deletenodes(head->child1);
	if(head->child2)
		Deletenodes(head->child2);
	if(head->child3)
		Deletenodes(head->child3);
	if(head->child4)
		Deletenodes(head->child4);
	if(!head->child1 && !head->child2 && !head->child3 && !head->child4)
		free(head);
}

bool cutshort(node* p)
{
//This function cut many of the circluar paths
	node* n = p->parent;
	while(n->parent){
		if(n->x == p->x && n->y == p->y){
			if(1)
				return 1;
		}
	}
	return 0;
}

void expand(node* a)
{
	node* q;	node* w;
	node* e;	node* r;
	char* tmp = direction[a->x][a->y];
	int i = 0;
	while(tmp[i])
	{
		switch(tmp[i]){
		case '1': 
			q = Createnode(a , a->x , a->y+1);
			if( cutshort(q) )
			{
				free(q);
				q = NULL;
			}
			if(q){
				if( q->coin == MAXCOIN ){
					if(q->depth > bestnode.depth)
						bestnode = *q;
				}
				expand(q);
			}
			else 
				return;
			if(q->depth%10 == 0) 
				cout << q->depth << endl;
			break;
		case '2':
			w = Createnode(a , a->x-1 , a->y);
			if( cutshort(w) )
			{
				free(q);
				w = NULL;
			}
			if(w){
				if( w->coin == MAXCOIN ){
					if(w->depth > bestnode.depth)
						bestnode = *w;
				}
				expand(w);
			}
			else return;
			break;
		case '3':
			e = Createnode(a , a->x , a->y-1);
			if( cutshort(e) )
			{
				free(e);
				e = NULL;
			}
			if(e){
				if( e->coin == MAXCOIN ){
					if(e->depth > bestnode.depth)
						bestnode = *e;
				}
				expand(e);
			}
			else return;
			break;
		case '4':
			r = Createnode(a , a->x+1 , a->y);
			if( cutshort(r) )
			{
				free(r);
				r = NULL;
			}
			if(r){
				if( r->coin == MAXCOIN ){
					if(r->depth > bestnode.depth)
						bestnode = *r;
				}
				expand(r);
			}
			else return;
			break;
		}
		i++;
	}
}

void ReadDirection( FILE* fp )
{
// this might have some problem regarding the coordination.
	int total;
	fscanf(fp,"%d",&total);
	for(int i = 0; i < N; i++)
	{
		for(int j = 0; j < M; j++)
		{
			fscanf(fp,"%s",direction[i][M-j+1]);
		}
	}
}

void ReadCoin( FILE* fp)
{
	int total,a,b;
	fscanf(fp,"%d",&total);
	for(int i = 0; i < total; i++)
	{
		fscanf(fp,"%d %d",&a,&b);
		coinmap[a][b] = 1;
	}

}

//=====================================================================
int _tmain(int argc, _TCHAR* argv[])
{
	node* head;
	head = Createnode(NULL,2,3);
	FILE* fp = fopen("direction.txt","r");
	ReadDirection(fp);
	fclose(fp);
	fp = fopen("coin.txt","r");
	ReadCoin(fp);
	fclose(fp);
	//=================初始化完毕！=======================
	//search:
	expand(head);

	Deletenodes(head);
	system("pause");
	return 0;
}

