/*****************************************************************************
 *   bwspell.c     :  Program for spell checking of Bengali files.           *
 *                    This is an auxiliary program distributed with bwedit.  *
 *                    It can, however, be used as an independent and         *
 *                    self-sufficient program too. Type "bwspell h" for the  *
 *                    usage options.                                         *
 *                                                                           *
 *   Author        :  Abhijit Das (ad_rab@yahoo.com)                         *
 *   Last modified :  July 06 2002                                           *
 *****************************************************************************/

/*****************************************************************************

   Copyright (C) 1998-2002 by Abhijit Das [ad_rab@yahoo.com]

   This file is part of BWEDIT.

   BWEDIT is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   BWEDIT is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with BWEDIT; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

 *****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef UNICODE
#define ALPHSIZE 65536
#else
#define ALPHSIZE 256
#endif
#define DICTFILE "/usr/local/bwedit/lib/bw.dct"
#define CASEFILE "/usr/local/bwedit/lib/bw.cse"
#define ENCFILE "/usr/local/bwedit/lib/bn.enc"
#define ISCIIENCFILE "/usr/local/bwedit/lib/iscii.enc"
#define SPLCODELIM 4
typedef unsigned char uchar;
uchar **dictisc = NULL, **dictbng = NULL, **dictbtx = NULL;
uchar *gram = NULL;
uchar **caseisc = NULL;
uchar *ctype = NULL;
int dictSize, nCases;
uchar catcode[ALPHSIZE];
uchar syllSep = '_';
uchar **enc = NULL;
uchar **refCode = NULL, **rafalaCode = NULL;
uchar **jafalaCode = NULL, **chandraCode = NULL;
uchar hascode[3];
int *asc = NULL;
int nenc = 0, aenc = 0, stepSize = 16;
int nencRef = 0, nencRafala = 0, nencJafala = 0, nencChandra = 0;
uchar isciiEncTable[256][10];
int liberal = 0;

void addEnc ( uchar *c, int ascii )
{
   int i, insertIdx;

   if (enc == NULL) insertIdx = 0;
   else if (strcmp(c, enc[0]) < 0) insertIdx = 0;
   else {
      insertIdx = nenc;
      for (i=0; i<nenc; i++) {
         if (!(strcmp(c, enc[i]))) {
            fprintf(stderr, "Ignoring duplicate encoding for %s\n", c);
            return;
         }
         if (strcmp(c, enc[i]) < 0) { insertIdx = i; i = nenc; }
      }
   }
   if (aenc == nenc) {
      aenc += stepSize;
      enc = (uchar **)realloc(enc, aenc * sizeof(char *));
      asc = (int *)realloc(asc, aenc * sizeof(int));
   }
   for (i=nenc; i>insertIdx; i--) {
      enc[i] = NULL; enc[i] = enc[i-1]; asc[i] = asc[i-1];
   }
   enc[insertIdx] = NULL;
   enc[insertIdx] = (char *)malloc((strlen(c) + 1) * sizeof(char));
   strcpy(enc[insertIdx], c); asc[insertIdx] = ascii; nenc++;
}

void procSplCode ( uchar *c , uchar **codeList, int *ncode )
{
   uchar *idx, *last;
   int i, inserted;

   last = c; while (*last) last++;
   while (strlen(c) > 0) {
      idx = strchr(c, ',');
      if (idx == NULL) idx = last;
      else {*idx = 0; idx++;}
      inserted = 0;
      for (i=0; i<*ncode; i++) {
         if (!(strcmp(c, codeList[i]))) inserted = 1;
      }
      if (!inserted) {
         if (*ncode == SPLCODELIM) {
            fprintf(stderr, "Too many codes for special primitives ...\n");
            return;
         }
         codeList[*ncode] = (char *)malloc((strlen(c) + 1) * sizeof(char));
         strcpy(codeList[*ncode], c);
         *ncode += 1;
      }
      c = idx;
   }
}

void readEnc ( uchar v[], uchar c[] )
{
   FILE *fp;
   uchar *idx, *lhs, *rhs, line[1000];

   fp = (FILE *)fopen(ENCFILE, "r");
   if (fp == NULL) {
      fprintf(stderr, "Unable to open encoding file: %s\n", ENCFILE);
      exit(-1);
   }
   while (!feof(fp)) {
      fgets(line, 1024, fp);
      line[strlen(line) - 1] = 0;
      if (strlen(line) > 0) {
         idx = strchr(line, '#');
         if (idx != NULL) *idx = 0;
         if (strlen(line) > 0) {
            idx = strchr(line, ':');
            if (idx != NULL) {
               *idx = 0; lhs = line; rhs = idx; rhs++;
               while (((*lhs == ' ') || (*lhs == '\t')) && (lhs != idx)) lhs++;
               if (idx != lhs) {
                  idx--;
                  while ((*idx == ' ') || (*idx == '\t')) { *idx = 0; idx--; }
                  while ((*rhs == ' ') || (*rhs == '\t')) rhs++;
                  idx = rhs;
                  while ((*idx != ' ') && (*idx != '\t') && (*idx != 0)) idx++;
                  *idx = 0;
                  if (*rhs != 0) {
                     if (!(strcmp(lhs, "VowelAlphabet"))) strcpy(v,rhs);
                     else if (!(strcmp(lhs, "ConsonantAlphabet"))) strcpy(c,rhs);
                     else if (!(strcmp(lhs, "SyllableSeparator"))) syllSep = *rhs;
                     else if (!(strcmp(lhs, "HasantaCode"))) { addEnc(rhs, 95); strcpy(hascode, rhs); }
                     else if (!(strcmp(lhs, "RefCode"))) procSplCode(rhs, refCode, &nencRef);
                     else if (!(strcmp(lhs, "RafalaCode"))) procSplCode(rhs, rafalaCode, &nencRafala);
                     else if (!(strcmp(lhs, "JafalaCode"))) procSplCode(rhs, jafalaCode, &nencJafala);
                     else if (!(strcmp(lhs, "ChandrabinduCode"))) procSplCode(rhs, chandraCode, &nencChandra);
                     else if (*rhs == '\\') addEnc(lhs, atoi(++rhs));
                     else addEnc(lhs, *rhs);
                  }
               }
            }
         }
      }
   }
}

void initEnc ()
{
   int i;
   uchar v[ALPHSIZE], c[ALPHSIZE], tmpstr[10];

   for (i=0; i<ALPHSIZE; i++) catcode[i] = 0;
   strcpy(v, "aAeEiILoORuU");
   strcpy(c, "bBcCdDfFgGhHjJkKlmMnNpPqQrsStTvVwWxXyYZ^");
   refCode = (uchar **)malloc(SPLCODELIM * sizeof(char *));
   rafalaCode = (uchar **)malloc(SPLCODELIM * sizeof(char *));
   jafalaCode = (uchar **)malloc(SPLCODELIM * sizeof(char *));
   chandraCode = (uchar **)malloc(SPLCODELIM * sizeof(char *));
   readEnc(v,c);
   for (i=strlen(v) - 1; i>=0; i--) catcode[v[i]] = 2;
   for (i=strlen(c) - 1; i>=0; i--) catcode[c[i]] = 3;
   catcode[syllSep] = 1;
   if (!nencRef) {
      sprintf(tmpstr, "r,^r");
      procSplCode(tmpstr, refCode, &nencRef);
   }
   if (!nencRafala) {
      sprintf(tmpstr, "r,^r");
      procSplCode(tmpstr, rafalaCode, &nencRafala);
   }
   if (!nencJafala) {
      sprintf(tmpstr, "y,^y");
      procSplCode(tmpstr, jafalaCode, &nencJafala);
   }
   if (!nencChandra) {
      sprintf(tmpstr, "^");
      procSplCode(tmpstr, chandraCode, &nencChandra);
   }
}

void readISCIIEnc ( )
{
   int i;
   FILE *fp = NULL;
   uchar *idx, *lhs, *rhs, line[1000];

   for (i=0; i<256; i++) isciiEncTable[i][0] = '\0';
   fp = (FILE *)fopen(ISCIIENCFILE, "r");
   if (fp == NULL) {
      fprintf(stderr, "Warning: encoding file \"%s\" not found.\n", ISCIIENCFILE);
      exit(6);
   }
   while (!feof(fp)) {
      fgets(line, 1024, fp);
      line[strlen(line) - 1] = 0;
      if (strlen(line) > 0) {
         idx = strchr(line, '#');
         if (idx != NULL) *idx = 0;
         if (strlen(line) > 0) {
            idx = strchr(line, ':');
            if (idx != NULL) {
               *idx = 0; lhs = line; rhs = idx; rhs++;
               while (((*lhs == ' ') || (*lhs == '\t')) && (lhs != idx)) lhs++;
               if (idx != lhs) {
                  idx--;
                  while ((*idx == ' ') || (*idx == '\t')) { *idx = 0; idx--; }
                  while ((*rhs == ' ') || (*rhs == '\t')) rhs++;
                  idx = rhs;
                  while ((*idx != ' ') && (*idx != '\t') && (*idx != 0)) idx++;
                  *idx = 0;
                  if (*rhs != 0) sprintf(isciiEncTable[atoi(lhs)], "%s", rhs);
               }
            }
         }
      }
   }
}

int readDict ( uchar texttype )
{
   FILE *fp;
   uchar line[1025];
   int nent, i, curr;

   fprintf(stderr, "Reading dictionary .."); fflush(stderr);
   fp = (FILE *)fopen(DICTFILE, "r");
   if (fp == NULL) {
      fprintf(stderr, "Error in bwspell: dictionary file not found\n");
      exit(-1);
   }
   nent = 0;
   while (!feof(fp)) {
      fgets(line, 1024, fp);
      nent++;
   }
   fprintf(stderr, "."); fflush(stderr);
   dictisc = (uchar **)malloc(nent * sizeof(uchar *));
   if (texttype == 1) dictbng = (uchar **)malloc(nent * sizeof(uchar *));
   if (texttype == 2) dictbtx = (uchar **)malloc(nent * sizeof(uchar *));
   gram = (uchar *)malloc(nent * sizeof(uchar));
   fprintf(stderr, "."); fflush(stderr);
   fseek(fp,0,SEEK_SET);
   for (curr=i=0; i<nent; i++) {
      int idx;
      uchar *cp, *btxword, *bngword;
      fgets(line, 1024, fp);
      line[strlen(line) - 1] = 0;
      if (strlen(line) > 0) {
         cp = strchr(line,':');
         if (cp != NULL) {
            *cp = '\0';
            bngword = ++cp;
            cp = strchr(cp,':');
            if (cp != NULL) {
               *cp = '\0';
               btxword = ++cp;
               cp = strchr(cp,':');
               if (cp != NULL) {
                  *cp = '\0';
                  cp++;
                  if ( (strlen(line) > 0) && (strlen(bngword) > 0) &&
                       (strlen(btxword) > 0) && (strlen(cp) > 0) ) {
                     dictisc[curr] = (uchar *)malloc((strlen(line) + 1) * sizeof(uchar));
                     strcpy(dictisc[curr], line);
                     if (texttype == 1) {
                        dictbng[curr] = (uchar *)malloc((strlen(bngword) + 1) * sizeof(uchar));
                        strcpy(dictbng[curr], bngword);
                     }
                     if (texttype == 2) {
                        dictbtx[curr] = (uchar *)malloc((strlen(btxword) + 1) * sizeof(uchar));
                        strcpy(dictbtx[curr], btxword);
                     }
                     gram[curr] = '\0';
                     while (*cp != '\0') {
                        gram[curr] |= (1 << (*cp - 48));
                        cp++;
                     }
                     curr++;
                  }
               }
            }
         }
      }
   }
   fclose(fp);
   fprintf(stderr, "."); fflush(stderr);
   if (nent != curr) {
      nent = curr;
      dictisc = (uchar **)realloc(dictisc, nent * sizeof(uchar *));
      dictbng = (uchar **)realloc(dictbng, nent * sizeof(uchar *));
      dictbtx = (uchar **)realloc(dictbtx, nent * sizeof(uchar *));
      gram = (uchar *)realloc(gram, nent * sizeof(uchar));
   }
   fprintf(stderr, ". done\n"); fflush(stderr);
   return(nent);
}

int readCases ( )
{
   FILE *fp;
   uchar line[1025];
   int nent, i, curr;

   fprintf(stderr, "Reading case endings .."); fflush(stderr);
   fp = (FILE *)fopen(CASEFILE, "r");
   if (fp == NULL) {
      fprintf(stderr, "Error in bwspell: case ending file not found\n");
      exit(-1);
   }
   nent = 0;
   while (!feof(fp)) {
      fgets(line, 1024, fp);
      nent++;
   }
   fprintf(stderr, "."); fflush(stderr);
   caseisc = (uchar **)malloc(nent * sizeof(uchar *));
   ctype = (uchar *)malloc(nent * sizeof(uchar));
   fprintf(stderr, "."); fflush(stderr);
   fseek(fp,0,SEEK_SET);
   for (curr=i=0; i<nent; i++) {
      int idx;
      uchar *cp;
      fgets(line, 1024, fp);
      line[strlen(line) - 1] = 0;
      if (strlen(line) > 0) {
         cp = strchr(line,':');
         if (cp != NULL) {
            *cp = '\0';
            cp++;
            if ((strlen(line) > 0) && (strlen(cp) > 0)) {
               caseisc[curr] = (uchar *)malloc((strlen(line) + 1) * sizeof(uchar));
               strcpy(caseisc[curr], line);
               ctype[curr] = '\0';
               if (strcmp(cp,"0")) {
                  while (*cp != '\0') {
                     ctype[curr] |= (1 << (*cp - 49));
                     cp++;
                  }
               }
               curr++;
            }
         }
      }
   }
   fclose(fp);
   fprintf(stderr, "."); fflush(stderr);
   if (nent != curr) {
      nent = curr;
      caseisc = (uchar **)realloc(caseisc, nent * sizeof(uchar *));
      ctype = (uchar *)realloc(ctype, nent * sizeof(uchar));
   }
   fprintf(stderr, ". done\n"); fflush(stderr);
   return(nent);
}

void helpMsg ( )
{
   fprintf(stderr, "Usage: bwspell <option> <input_file> [<output_file>]\n");
   fprintf(stderr, "Here <option> is <operation><text_type>[<modifier>]\n");
   fprintf(stderr, "The operations are\n");
   fprintf(stderr, "c  Check spelling\n");
   fprintf(stderr, "m  Find closely spelt words (near matches)\n");
   fprintf(stderr, "h  Display help message and quit\n");
   fprintf(stderr, "s  Show dictionary and quit\n");
   fprintf(stderr, "v  Display Version info and quit\n");
   fprintf(stderr, "Text types supported are\n");
   fprintf(stderr, "b,m,1  Bengali text\n");
   fprintf(stderr, "r,t,2  Roman transliteration of Bengali text\n");
   fprintf(stderr, "i,3    ISCII text\n");
   fprintf(stderr, "The modifier supported is s which directs bwspell to treat the\n");
   fprintf(stderr, "next argument as the input string (instead of a file name).\n");
   fprintf(stderr, "If no output filenames are specified, output goes to stdout.\n");
}

void versionInfo ( )
{
   fprintf(stderr, "bwspell: Version 1.0 (June 2002)\nAuthor: Abhijit Das (Barda) [ad_rab@yahoo.com]\n");
}

void showDict ( )
{
   int i, dictSize;
   uchar c, oldc = '\0', flag;

   dictSize = readDict(1);
   printf("\n");
   for (i=0; i<dictSize; i++) {
      c = dictisc[i][0];
      if (c > 160) {
         if (c != oldc) { printf("%\n"); oldc = c; }
         printf(" %s  ",dictbng[i]);
         flag = 0;
         if (gram[i] & 1) { printf("ib"); flag = 1; }
         if (gram[i] & 2) { printf("%sibN",(flag) ? "," : ""); flag = 1; }
         if (gram[i] & 4) { printf("%ssb^",(flag) ? "," : ""); flag = 1; }
         if (gram[i] & 8) { printf("%sab%c",(flag) ? "," : "",14); flag = 1; }
         if (gram[i] & 16) printf("%si%c",(flag) ? "," : "",133);
         printf("\n");
      }
   }
}

int fileSize ( FILE *fp )
{
   int n = 0;
   char c;

   if (fp == NULL) {
      fprintf(stderr, "bwspell: Unable to access file\n");
      return (0);
   }
   while (!feof(fp)) {
      fscanf(fp, "%c", &c);
      n++;
   }
   return(n);
}

void readFile ( uchar *fname , uchar **input )
{
   FILE *fp;
   uchar *last, ch;
   int i, len;

   fp = fopen(fname, "r");
   if (fp == NULL) {
      fprintf(stderr, "bwspell: Input file \"%s\" not found\n", fname);
      exit(3);
   }
   len = fileSize(fp);
   fseek(fp, 0, SEEK_SET);
   *input = (uchar *)malloc((len + 1) * sizeof(uchar));
   last = *input;
   for (i=0; i<len; i++) {
      fscanf(fp, "%c", &ch);
      *last = ch;
      last++;
   }
   *last = '\0';
   fclose(fp);
}

int findEnc ( uchar *c )
{
   int min, max, mid, compres;

   compres = strcmp(c,enc[min = 0]);
   if (!compres) return (asc[min]);
   if (compres < 0) return (-1);
   compres = strcmp(c,enc[max = nenc - 1]);
   if (!compres) return (asc[max]);
   if (compres > 0) return (-1);
   while (max > min + 1) {
      mid = (min + max) / 2;
      compres = strcmp(c,enc[mid]);
      if (!compres) return(asc[mid]);
      if (compres > 0) min = mid; else max = mid;
   }
   return (-1);
}

int findLigEnc (char *c)
{
   char cc[3];

   cc[0] = c[0]; cc[1] = c[1]; cc[2] = 0;
   return (findEnc(cc));
}

void btxToISCII ( uchar *c, uchar *op )
{
   int len, i, j, tmp, ref, rafala, jafala, chandra, tban, tswar, nc;
   uchar ban[51], swar[11], punc[1024], *t, *tt, *d;

   len = strlen(c);
   d = op;
   while (*c) {
      if (catcode[*c] < 2) {
         if ( (catcode[*c] == 0) || (findLigEnc(c) >= 0) ) {
            *d = 232; d++;
            *d = 232; d++;
            if (strlen(hascode) == 2) c++;
         }
         c++;
         *d = '\0';
      } else if (catcode[*c] == 2) {
         t = swar; do { *t = *c; t++; c++; } while (catcode[*c] == 2);
         *t = 0; tmp = findEnc(swar);
         switch (tmp) {
            case 97 : sprintf(d, "%s", isciiEncTable[97]); break;
            case 65 : sprintf(d, "%c", 165); break;
            case 1  :
            case 105: sprintf(d, "%s", isciiEncTable[1]); break;
            case 2  :
            case 73 : sprintf(d, "%s", isciiEncTable[2]); break;
            case 3  :
            case 117: sprintf(d, "%s", isciiEncTable[3]); break;
            case 4  :
            case 85 : sprintf(d, "%s", isciiEncTable[4]); break;
            case 5  :
            case 87 : sprintf(d, "%s", isciiEncTable[5]); break;
            case 6  :
            case 101: sprintf(d, "%s", isciiEncTable[6]); break;
            case 7  :
            case 69 : sprintf(d, "%s", isciiEncTable[7]); break;
            case 8  : sprintf(d, "%s", isciiEncTable[8]); break;
            case 79 :
            case 111: sprintf(d, "%s", isciiEncTable[111]); break;
            case 14 : sprintf(d, "%s%s%s", isciiEncTable[97], isciiEncTable[14], isciiEncTable[65]); break;
            default : sprintf(d, " ");
         }
      } else {
         t = ban; do { *t = *c; t++; c++; } while (catcode[*c] == 3); *t = 0;
         t = swar; while (catcode[*c] == 2) { *t = *c; t++; c++; } *t = 0;
         if (strlen(swar) == 0) tswar = 97; else {
            tswar = findEnc(swar);
            if (tswar < 0) tswar = 0;
         }
         ref = rafala = jafala = chandra = 0;
         tban = findEnc(ban); t = ban;
         if (tban < 0) {
            int done = 0;
            while ((tban < 0) && (!done)) {
               done = 1;
               for (i=0; (done) && (i<nencChandra); i++) {
                  tt = t; tmp = strlen(tt);
                  for (j=0; j<(tmp-(int)strlen(chandraCode[i])); j++) tt++;
                  if (!strcmp(tt,chandraCode[i])) {
                     *tt = 0; done = 0; chandra = 1;
                  }
               }
               for (i=0; (done) && (i<nencRef); i++) {
                  if (!(strncmp(t, refCode[i], strlen(refCode[i])))) {
                     ref = 1; done = 0;
                     for (j=0; j<strlen(refCode[i]); j++) t++;
                  }
               }
               for (i=0; (done) && (i<nencRafala); i++) {
                  tt = t; tmp = strlen(tt);
                  for (j=0; j<(tmp-(int)strlen(rafalaCode[i])); j++) tt++;
                  if (!strcmp(tt,rafalaCode[i])) {
                     *tt = 0; done = 0; rafala = 1;
                  }
               }
               for (i=0; (done) && (i<nencJafala); i++) {
                  tt = t; tmp = strlen(tt);
                  for (j=0; j<(tmp-(int)strlen(jafalaCode[i])); j++) tt++;
                  if (!strcmp(tt,jafalaCode[i])) {
                     *tt = 0; done = 0; jafala = 1;
                  }
               }
               tban = findEnc(t);
            }
         }
         if (tban < 0) {
            if ((chandra) && (strlen(t) == 0)) { sprintf(ban, "%s", isciiEncTable[119]); chandra = 0; }
            else sprintf(ban, "%s %s%s", ref ? isciiEncTable[94] : (uchar *)(""), rafala ? isciiEncTable[15] : (uchar *)(""), jafala ? isciiEncTable[14] : (uchar *)(""));
         } else sprintf(ban, "%s%s%s%s", ref ? isciiEncTable[94] : (uchar *)(""), isciiEncTable[tban], rafala ? isciiEncTable[15] : (uchar *)(""), jafala ? isciiEncTable[14] : (uchar *)(""));
         switch (tswar) {
            case 97 : sprintf(d, "%s", ban); break;
            case 65 : sprintf(d, "%s%c", ban, 218); break;
            case 1  :
            case 105: sprintf(d, "%s%c", ban, 219); break;
            case 2  : 
            case 73 : sprintf(d, "%s%c", ban, 220); break;
            case 3  : 
            case 117: sprintf(d, "%s%c", ban, 221); break;
            case 4  : 
            case 85 : sprintf(d, "%s%c", ban, 222); break;
            case 5  :
            case 87 : sprintf(d, "%s%c", ban, 223); break;
            case 6  :
            case 101: sprintf(d, "%s%c", ban, 225); break;
            case 7  :
            case 69 : sprintf(d, "%s%c", ban, 226); break;
            case 8  : sprintf(d, "%s%c", ban, 229); break;
            case 79 :
            case 111: sprintf(d, "%s%c", ban, 230); break;
            case 14 : sprintf(d, "%s%s%c", ban, isciiEncTable[14], 218); break;
            default : sprintf(d, "%s ", ban);
         }
         while (*d) d++;
         if (chandra) sprintf(d, "%s", isciiEncTable[119]);
      }
      while (*d) d++;
   }
}

int wordExists ( uchar *word )
{
   int min, max, mid, compres;

   compres = strcmp(word,dictisc[min = 0]);
   if (!compres) return (min);
   if (compres < 0) return (-1);
   compres = strcmp(word,dictisc[max = dictSize - 1]);
   if (!compres) return (max);
   if (compres > 0) return (-1);
   while (max > min + 1) {
      mid = (min + max) / 2;
      compres = strcmp(word,dictisc[mid]);
      if (!compres) return(mid);
      if (compres > 0) min = mid; else max = mid;
   }
   return (-1);
}

int isSuffix ( uchar *word , uchar *sfx ) {
   int wlen, slen, i;

   wlen = strlen(word);
   slen = strlen(sfx);
   if (wlen < slen) return(0);
   word = &(word[wlen-slen]);
   if (!strcmp(word,sfx)) return(1); else return(0);
}

int endingType ( uchar *word )
{
   int wlen;
   uchar lastchar;

   wlen = strlen(word);
   if (wlen == 0) return(0);
   lastchar = word[wlen-1];
   if ((lastchar >= 164) && (lastchar <= 170)) return(lastchar-163);
   if (lastchar == 172) return(8);
   if (lastchar == 173) return(9);
   if (lastchar == 176) return(10);
   if (lastchar == 177) return(11);
   if ((lastchar >= 218) && (lastchar <= 223)) return(lastchar-205);
   if (lastchar == 225) return(19);
   if (lastchar == 226) return(20);
   if (lastchar == 229) return(21);
   if (lastchar == 230) return(22);
   if ((lastchar >= 179) && (lastchar <= 216)) return(12);
   if (lastchar == 233) {
      if (wlen <= 2) return(25);
      if (word[wlen-2] == 232) return(23);
      return(12);
   }
   if (lastchar == 232) {
      if (wlen <= 2) return(25);
      if (word[wlen-2] == 232) return(23);
      return(25);
   }
   if ((lastchar == 161) || (lastchar == 162) || (lastchar == 163)) return(24);
   return(25);
}

int numSyll ( uchar *word )
{
   uchar w[256];
   int i, wlen, nsyll;

   strcpy(w,word);
   wlen = strlen(w);
   if (w[wlen-1] == 161) w[--wlen] = '\0';
   if ( (w[wlen-1] >= 164) && (w[wlen-1] <= 177) ) return((wlen == 1) ? 1 : 0);
   i = nsyll = 0;
   while ( i < wlen ) {
      if ((w[i] >= 164) && (w[i] <= 177)) { nsyll++; i++; }
      else if ((w[i] >= 179) && (w[i] <= 216)) {
         i++;
         if (w[i] == 0) return(nsyll + 1);
         else if (((w[i] >= 164) && (w[i] <= 177)) || ((w[i] >= 179) && (w[i] <= 216))) nsyll++;
         else if ((w[i] >= 218) && (w[i] <= 230)) { nsyll++; i++; }
         else if (w[i] == 233) { nsyll++; i++; }
         else if (w[i] == 232) {
            do i++; while ((w[i] == 217) || (w[i] == 232) || (w[i] == 233));
         }
      } else return(0);
   }
   return(nsyll);
}

int checkCases ( uchar *word )
{
   int i, wlen, l, k;
   uchar pfx[256];

   wlen = strlen(word);
   for (i=0; i<nCases; i++) {
      l = strlen(caseisc[i]);
      if (isSuffix(word, caseisc[i])) {
         l = wlen - strlen(caseisc[i]);
         pfx[l] = '\0';
         for (l--; l>=0; l--) pfx[l] = word[l];
         k = endingType(pfx);
         l = wordExists(pfx);
         if ( (l >= 0) && (gram[l] & 1) ) {
            if ( (k != 0) && (k != 25) ) {
               if (ctype[i] == 0) return(0);
               if ((k >= 12) && (k <= 22) && (numSyll(pfx) == 1)) {
                  if (ctype[i] & 8) return(0);
               } else {
                  if ( (k == 12) && (ctype[i] & 1) ) return(0);
                  if ( ( (k == 13) || (k == 19) || (k == 21) ) && (ctype[i] & 2) ) return(0);
                  if ( (k >= 14) && (k <= 18) && (ctype[i] & 4) ) return(0);
                  if ( ( (k == 20) || (k == 22) ) && (ctype[i] & 4) ) return(0);
                  if ( (k >= 1) && (k <= 11) && (ctype[i] & 8) ) return(0);
               }
            }
         } else if ( (k == 12) && (ctype[i] & 1) ) {
            l = strlen(pfx);
            pfx[l] = 232;
            pfx[l+2] = '\0';
            if (pfx[l-1] == 194) {
               pfx[l+1] = 233;
               l = wordExists(pfx);
               if ( (l>=0) && (gram[l] & 1) ) return(0);
            }
            pfx[l+1] = 232;
            l = wordExists(pfx);
            if ( (l>=0) && (gram[l] & 1) ) return(0);
         }
      }
   }
   return(1);
}

int checkParts ( uchar *word )
{
   int wlen, i, l;
   uchar word1[256], *word2;

   wlen = strlen(word);
   if (wlen <= 1) return(1);
   word2 = word;
   for (i=1; i<wlen; i++) {
      word1[i-1] = word[i-1];
      word1[i] = 0;
      word2++;
      if ( (wordExists(word1) >= 0) && (checkSpell(word2,2) == 0) ) return(0);
   }
   return(1);
}

int checkSpell ( uchar *word , int flag )
{
   uchar sfx[2], pfx[256];
   int i, l;

   if (strlen(word) == 0) return(3);
   if (strchr(word, ' ') != NULL) return(1);
   if (wordExists(word) >= 0) return(0);
   if (flag != 1) {
      sfx[0] = 166; sfx[1] = 0;
      if (isSuffix(word,sfx)) {
         l = strlen(word);
         for (i=l-2; i>=0; i--) pfx[i] = word[i];
         pfx[l-1] = 0;
         l = wordExists(pfx);
         if ( (l >= 0) && (gram[l] != 8) ) return(0);
         if (checkSpell(pfx,1) == 0) return(0);
      }
      sfx[0] = 176; sfx[1] = 0;
      if (isSuffix(word,sfx)) {
         l = strlen(word);
         for (i=l-2; i>=0; i--) pfx[i] = word[i];
         pfx[l-1] = 0;
         l = wordExists(pfx);
         if ( (l >= 0) && (gram[l] != 8) ) return(0);
         if (checkSpell(pfx,1) == 0) return(0);
      }
   }
   if (checkCases(word) == 0) return(0);
   if ( (flag != 2) && (checkParts(word) == 0) ) return(liberal ? 0 : 4);
   return(2);
}

void bngCheckInput ( char *input , FILE *fp )
{
   fprintf(stderr, "This is not implemented yet ...\n");
}

void btxCheckInput ( char *c , FILE *fp ) 
{
   int lineno, colno, start, end, bngmode = 1, status;
   uchar input[1024], output[1024], *cp;

   lineno = 1;
   colno = 0;
   *input = 0;
   cp = input;
   while (*c) {
      if (!bngmode) {
         if (*c == '#') {
            if (strncmp(c,"##",2)) bngmode = 1; else { c++; colno++; }
            colno++;
         } else if (*c == '\n') {
            bngmode = 1;
            lineno++;
            colno = 0;
         } else colno++;
         c++;
      } else if (*c == '#') {
         if (strncmp(c,"##",2)) bngmode = 0; else { c++; colno++; }
         c++; colno++;
      } else if (catcode[*c] < 2) {
         if (*c == '\n') {
            lineno++;
            colno = 0;
         } else colno++;
         c++;
      } else {
         int done;
         start = colno;
         done = 0;
         while (!done) {
            if ( (catcode[*c] >= 2) ||
                 ((catcode[*c] == 1) && (findLigEnc(c) < 0)) ) {
               *cp = *c; c++; cp++; colno++;
            } else if (!strncmp(c,hascode,strlen(hascode))) {
               *cp = *c; c++; cp++; colno++;
               if (strlen(hascode) == 2) { *cp = *c; c++; cp++; colno++; }
            } else done = 1;
         }
         *cp = 0;
         end = colno;
         btxToISCII(input,output);
         status = checkSpell(output,0);
         if (status) fprintf(fp, "%d.%d %d.%d %d\n", lineno, start, lineno, end, status);
         *input = 0;
         cp = input;
      }
   }
}

void iscCheckInput ( char *input , FILE *fp ) 
{
   fprintf(stderr, "This is not implemented yet ...\n");
}

int main ( int argc , char *argv[] )
{
   uchar task, texttype, *input = NULL;
   FILE *fp;

   if (argc == 1) {
      fprintf(stderr, "bwspell: Too few arguments\n");
      fprintf(stderr, "Type \"bwspell h\" for command line options\n");
      exit(1);
   }
   if (argv[1][0] == '-') argv[1]++;
   task = argv[1][0];
   if ((task >= 'A') && (task <= 'Z')) task += 32;
   if (task == '\0') task = ' ';
   if (task == 'h') { helpMsg(); exit(-2); }
   if (task == 'v') { versionInfo(); exit(-3); }
   if (task == 's') { showDict(); exit(0); }
   if ((task != 'c') && (task != 'm')) {
      fprintf(stderr, "bwspell: unknown operation \'%c\'\n", task);
      fprintf(stderr, "Type \"bwspell h\" for command line options\n");
      exit(1);
   }
   if (argc == 2) {
      fprintf(stderr, "bwspell: Too few arguments\n");
      fprintf(stderr, "Type \"bwspell h\" for command line options\n");
      exit(1);
   }
   argv[1]++;
   texttype = argv[1][0];
   if ((texttype >= 'A') && (texttype <= 'Z')) texttype += 32;
   if (texttype == '\0') texttype = ' ';
   switch (texttype) {
      case 'b':
      case 'm':
      case '1': readISCIIEnc(); texttype = 1; break;
      case 'r':
      case 't':
      case '2': initEnc(); readISCIIEnc(); texttype = 2; break;
      case 'i':
      case '3': texttype = 3; break;
      default :
         fprintf(stderr, "bwspell: Unknown text type \'%c\'\n", texttype);
         fprintf(stderr, "Type \"bwspell h\" for command line options\n");
         exit(1);
   }
   argv[1]++;
   while (argv[1][0]) {
      if ( (argv[1][0] == 's') || (argv[1][0] == 'S') ) {
         if (input == NULL) {
            input = (char *)malloc((strlen(argv[2]) + 2) * sizeof(char));
            sprintf(input, "%s\n", argv[2]);
         }
      } else if ( (argv[1][0] == 'l') || (argv[1][0] == 'L') ) {
         liberal = 1;
      } else {
         fprintf(stderr, "bwspell: Unknown modifier \'%c\'\n", argv[1][0]);
         fprintf(stderr, "Type \"bwspell h\" for command line options\n");
         exit(1);
      }
      argv[1]++;
   }
   if (input == NULL) readFile(argv[2], &input);
   if (argc == 3) fp = stdout; else {
      fp = (FILE *)fopen(argv[3], "w");
      if (fp == NULL) {
         fprintf(stderr, "bwspell: Unable to write file \"%s\"\n", argv[3]);
         exit(4);
      }
   }
   dictSize = readDict(texttype);
   nCases = readCases();
   if (task == 'c') {
      switch (texttype) {
         case 1 : bngCheckInput(input,fp); break;
         case 2 : btxCheckInput(input,fp); break;
         case 3 : iscCheckInput(input,fp); break;
      }
   }
   if (task == 'm') {
      fprintf(stderr, "This is not implemented yet ...\n");
   }
   exit(0);
}

/* End of bwspell.c */
