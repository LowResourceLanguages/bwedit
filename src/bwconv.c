/*****************************************************************************
 *   bnconv.c      :  Program for converting Bengali files among various     *
 *                    formats. This is an auxiliary program distributed      *
 *                    with bwedit. It can, however, be used as an            *
 *                    independent and self-sufficient program too. Type      *
 *                    "bwconv h" for the usage options.                      *
 *                                                                           *
 *   Author        :  Abhijit Das (ad_rab@yahoo.com)                         *
 *   Last modified :  July 03 2002                                           *
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
#define ENCFILE "/usr/local/bwedit/lib/bn.enc"
#define BWTIENCFILE "/usr/local/bwedit/lib/bwti.enc"
#define ISCIIENCFILE "/usr/local/bwedit/lib/iscii.enc"
#define SPLCODELIM 4

char catcode[ALPHSIZE];
char syllSep = '_';
char **enc = NULL;
char **refCode = NULL, **rafalaCode = NULL;
char **jafalaCode = NULL, **chandraCode = NULL;
int *asc = NULL;
int nenc = 0, aenc = 0, stepSize = 16;
int nencRef = 0, nencRafala = 0, nencJafala = 0, nencChandra = 0;

void addEnc ( char *c, int ascii)
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
      enc = (char **)realloc(enc, aenc * sizeof(char *));
      asc = (int *)realloc(asc, aenc * sizeof(int));
   }
   for (i=nenc; i>insertIdx; i--) {
      enc[i] = NULL; enc[i] = enc[i-1]; asc[i] = asc[i-1];
   }
   enc[insertIdx] = NULL;
   enc[insertIdx] = (char *)malloc((strlen(c) + 1) * sizeof(char));
   strcpy(enc[insertIdx], c); asc[insertIdx] = ascii; nenc++;
}

void procSplCode ( char *c , char **codeList, int *ncode )
{
   char *idx, *last;
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

void readEnc ( char v[], char c[] , char encfile[] )
{
   FILE *fp;
   char *idx, *lhs, *rhs, line[1000];

   fp = (FILE *)fopen(encfile, "r");
   if (fp == NULL) {
      fprintf(stderr, "Unable to open encoding file: %s\n", encfile);
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
                     else if (!(strcmp(lhs, "HasantaCode"))) addEnc(rhs, 95);
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
   fclose(fp);
}

void readTeXEnc ( char texEncTable[258][16] , int flag )
{
   int i;

   if (flag == 1) {
      FILE *fp;
      char *idx, *lhs, *rhs, line[1000];

      for (i=0; i<258; i++) texEncTable[i][0] = 0;
      fp = (FILE *)fopen(BWTIENCFILE, "r");
      if (fp == NULL) {
         fprintf(stderr, "Warning: encoding file \"%s\" not found.\n", BWTIENCFILE);
         fprintf(stderr, "Using default settings\n");
         flag = 0;
      } else {
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
                        if (*rhs != 0) sprintf(texEncTable[atoi(lhs)], "%s", rhs);
                     }
                  }
               }
            }
         }
         sprintf(texEncTable[256], "{\\AE}");
         sprintf(texEncTable[257], "{\\ae}");
      }
   }

   if (flag == 0) {
      for (i=0;i<32;i++) sprintf(texEncTable[i], "{\\char%d}", i);
      for (i=32;i<125;i++) sprintf(texEncTable[i], "%c", i);
      for (i=125;i<256;i++) sprintf(texEncTable[i], "{\\char%d}", i);
      sprintf(texEncTable[9], "\t");
      sprintf(texEncTable[10], "\n");
      sprintf(texEncTable[35], "{\\char38}");
      sprintf(texEncTable[36], "{\\char36}");
      sprintf(texEncTable[37], "{\\char37}");
      sprintf(texEncTable[38], "{\\char38}");
      sprintf(texEncTable[60], "..");
      sprintf(texEncTable[91], "{\\char91}");
      sprintf(texEncTable[92], "{\\char92}");
      sprintf(texEncTable[93], "{\\char93}");
      sprintf(texEncTable[94], "{\\char94}");
      sprintf(texEncTable[95], "{\\char95}");
      sprintf(texEncTable[123], "{\\char123}");
      sprintf(texEncTable[256], "a{\\char14}A");
      sprintf(texEncTable[257], "{\\char14}A");
   }
}

void readISCIIEnc ( char isciiEncTable[256][10] )
{
   int i;
   FILE *fp = NULL;
   char *idx, *lhs, *rhs, line[1000];

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

void initEnc ( char encfile[] )
{
   int i;
   char v[ALPHSIZE], c[ALPHSIZE], tmpstr[10];

   for (i=0; i<ALPHSIZE; i++) catcode[i] = 0;
   strcpy(v, "aAeEiILoORuU");
   strcpy(c, "bBcCdDfFgGhHjJkKlmMnNpPqQrsStTvVwWxXyYZ^");
   refCode = (char **)malloc(SPLCODELIM * sizeof(char *));
   rafalaCode = (char **)malloc(SPLCODELIM * sizeof(char *));
   jafalaCode = (char **)malloc(SPLCODELIM * sizeof(char *));
   chandraCode = (char **)malloc(SPLCODELIM * sizeof(char *));
   readEnc(v,c,encfile);
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

int findEnc ( char *c )
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

char findPuncEnc (char *c)
{
   char cc[2];
   int retval;

   cc[0] = c[0]; cc[1] = 0;
   retval = findEnc(cc);
   if (retval < 0) return(*c);
   return((char)retval);
}

int findLigEnc (char *c)
{
   char cc[3];

   cc[0] = c[0]; cc[1] = c[1]; cc[2] = 0;
   return (findEnc(cc));
}

void btxToLaTeX ( char *c, FILE *fp, int texPrintMode , int verbatim )
{
   int len, i, j, bngmode = 1, tmp, ref, rafala, jafala, chandra, tban, tswar;
   char ban[51], swar[11], punc[1024], *t, *tt;
   char texEncTable[258][16];

   readTeXEnc(texEncTable, texPrintMode);
   len = strlen(c);
   while (*c) {
      fflush(fp);
      if (!bngmode) {
         if (*c == '#') {
            if (strncmp(c, "##", 2)) {
               bngmode = 1; c++; fprintf(fp, "%c", 125);
            } else {
               fprintf(fp, "\\#"); c++; c++;
            }
         } else {
            switch (*c) {
               case  9  : fprintf(fp, "%s", (verbatim) ? "~" : "\t"); break;
               case 10  : fprintf(fp, "%c%s\n", 125, (verbatim) ? "\\mbox{}\\\\" : ""); bngmode = 1; break;
               case 32  : fprintf(fp, "%s", (verbatim) ? "~" : " "); break;
               case '$' : fprintf(fp, "{\\$}");  break;
               case '%' : fprintf(fp, "{\\%%}");  break;
               case '&' : fprintf(fp, "{\\char38}");  break;
               case '[' : fprintf(fp, "$[$");  break;
               case '\\': fprintf(fp, "{\\char92}");  break;
               case ']' : fprintf(fp, "$]$");  break;
               case '^' : fprintf(fp, "{\\char94}");  break;
               case '_' : fprintf(fp, "{\\char95}");  break;
               case '{' : fprintf(fp, "{\\{}"); break;
               case '}' : fprintf(fp, "{\\}}"); break;
               default  : fprintf(fp, "%c", *c);
            }
            c++;
         }
      } else if (*c == '#') {
         if (strncmp(c, "##", 2)) {
            bngmode = 0; c++; fprintf(fp, "%c\\rm ", 123);
         } else {
            fprintf(fp, "\\#"); c++; c++;
         }
      } else if (catcode[*c] < 2) {
         if ((catcode[*c] == 1) && (findLigEnc(c) < 0)) c++;
         else {
            t = punc;
            while ((*c != '#') && (*c != 0) && (catcode[*c] < 2)) {
               *t = findPuncEnc(c); t++; c++;
            }
            *t = 0; t = punc;
            while (strlen(t) > 0) {
               tmp = findLigEnc(t);
               if (tmp < 0) {
                  switch (*t) {
                     case  9  : fprintf(fp, "%s", (verbatim) ? "~" : "\t"); break;
                     case 10  : fprintf(fp, "%s\n", (verbatim) ? "\\mbox{}\\\\" : ""); break;
                     case 32  : fprintf(fp, "%s", (verbatim) ? "~" : " "); break;
                     default  : fprintf(fp, "%s", texEncTable[*t]);
                  }
                  t++;
               } else { t++; *t = tmp; }
            }
         }
      } else if (catcode[*c] == 2) {
         t = swar; do { *t = *c; t++; c++; } while (catcode[*c] == 2);
         *t = 0; tmp = findEnc(swar);
         switch (tmp) {
            case 97 : fprintf(fp, "a"); break;
            case 65 : fprintf(fp, "aA"); break;
            case 1  :
            case 105: fprintf(fp, "%s", texEncTable[1]); break;
            case 2  :
            case 73 : fprintf(fp, "%s", texEncTable[2]); break;
            case 3  :
            case 117: fprintf(fp, "%s", texEncTable[3]); break;
            case 4  :
            case 85 : fprintf(fp, "%s", texEncTable[4]); break;
            case 5  :
            case 87 : fprintf(fp, "%s", texEncTable[5]); break;
            case 6  :
            case 101: fprintf(fp, "%s", texEncTable[6]); break;
            case 7  :
            case 69 : fprintf(fp, "%s", texEncTable[7]); break;
            case 8  : fprintf(fp, "%s", texEncTable[8]); break;
            case 79 :
            case 111: fprintf(fp, "o"); break;
            case 14 : fprintf(fp, "%s", texEncTable[256]); break;
            default : fprintf(stderr, "Undefined vowel code : %s\n", swar);
         }
      } else {
         t = ban; do { *t = *c; t++; c++; } while (catcode[*c] == 3); *t = 0;
         t = swar; while (catcode[*c] == 2) { *t = *c; t++; c++; } *t = 0;
         if (strlen(swar) == 0) tswar = 97; else {
            tswar = findEnc(swar);
            if (tswar < 0) {
               fprintf(stderr, "Undefined vowel code : %s\n", swar);
               tswar = 97;
            }
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
         if ( ((tswar == 3) || (tswar == 117)) && (!jafala) && (!rafala) ) {
            switch (tban) {
               case 114: tban = 25; tswar = 97; break;
               case 104: tban = 27; tswar = 97; break;
               case 103: tban = 29; tswar = 97; break;
               case  83: tban = 30; tswar = 97; break;
               case 192: tban = 193; tswar = 97; break;
               case 226: tban = 227; tswar = 97; break;
               case 253: tban = 254; tswar = 97; break;
            }
         }
         if ( ((tswar == 4) || (tswar == 85)) && (tban == 114) && (!jafala) && (!rafala) ) {
            tban = 26; tswar = 97;
         }
         if ( ((tswar == 5) || (tswar == 87)) && (tban == 104) && (!jafala) && (!rafala) ) {
            tban = 28; tswar = 97;
         }
         if ((tban == 121) && (ref)) {
            tban = 114;
            jafala = 1;
            ref = 0;
         }
         if (tban < 0) {
            if ((chandra) && (strlen(t) == 0)) sprintf(ban, "w");
            else sprintf(ban, "\\ %s%s%s%s", ref ? "{\\Ref}" : "", chandra ? "w" : "", rafala ? "{\\rf}" : "", jafala ? "{\\jf}" : "");
         } else sprintf(ban, "%s%s%s%s%s", texEncTable[tban], ref ? "{\\Ref}" : "", chandra ? "w" : "", rafala ? "{\\rf}" : "", jafala ? "{\\jf}" : "");
         switch (tswar) {
            case 97 : fprintf(fp, "%s", ban); break;
            case 65 : fprintf(fp, "%sA", ban); break;
            case 1  :
            case 105: fprintf(fp, "i%s", ban); break;
            case 2  :
            case 73 : fprintf(fp, "%sI", ban); break;
            case 3  :
            case 117: fprintf(fp, "%su", ban); break;
            case 4  :
            case 85 : fprintf(fp, "%sU", ban); break;
            case 5  :
            case 87 : fprintf(fp, "%sW", ban); break;
            case 6  :
            case 101: fprintf(fp, "e%s", ban); break;
            case 7  :
            case 69 : fprintf(fp, "E%s", ban); break;
            case 8  : fprintf(fp, "e%sA", ban); break;
            case 79 :
            case 111: fprintf(fp, "e%sO", ban); break;
            case 14 : fprintf(fp, "%s%s", ban, texEncTable[257]); break;
         }
      }
   }
}

void btxToHTML ( char *c, FILE *fp , int verbatim )
{
   int len, i, j, bngmode = 1, tmp, ref, rafala, jafala, chandra, tban, tswar;
   char ban[51], swar[11], punc[1024], *t, *tt;
   int nwcp = 0;

   len = strlen(c);
   while (*c) {
      fflush(fp);
      if (!bngmode) {
         nwcp = 1;
         if (*c == '#') {
            if (strncmp(c, "##", 2)) {
               bngmode = 1; c++; fprintf(fp, "</TT>");
            } else {
               fprintf(fp, "#"); c++; c++;
            }
         } else {
            switch (*c) {
               case 9  : fprintf(fp, "%s", (verbatim) ? "&nbsp;" : "\t"); break;
               case 10 : fprintf(fp, "</TT>%s\n", (verbatim) ? "<BR>" : "");
                         bngmode = 1; nwcp = 0; break;
               case 32 : fprintf(fp, "%s", (verbatim) ? "&nbsp;" : " "); break;
               case 34 : fprintf(fp, "&quot;"); break;
               case 38 : fprintf(fp, "&amp;"); break;
               case 60 : fprintf(fp, "&lt;"); break;
               case 62 : fprintf(fp, "&gt;"); break;
               default : fprintf(fp, "%c", *c);
            }
            c++;
         }
      } else if (*c == '#') {
         nwcp = 1;
         if (strncmp(c, "##", 2)) {
            bngmode = 0; c++; fprintf(fp, "<TT>");
         } else {
            fprintf(fp, "#"); c++; c++;
         }
      } else if (catcode[*c] < 2) {
         if ((catcode[*c] == 1) && (findLigEnc(c) < 0)) c++;
         else {
            t = punc;
            while ((*c != '#') && (*c != 0) && (catcode[*c] < 2)) {
               *t = findPuncEnc(c); t++; c++;
            }
            *t = 0; t = punc;
            while (strlen(t) > 0) {
               tmp = findLigEnc(t);
               if (tmp < 0) {
                  switch (*t) {
                     case 9  : fprintf(fp, "%s", (verbatim) ? "&nbsp;" : "\t"); break;
                     case 10 : if (verbatim) fprintf(fp, "<BR>\n");
                               else fprintf(fp, "%s", (nwcp) ? "\n" : "<P>\n");
                               nwcp = 0; break;
                     case 32 : fprintf(fp, "%s", (verbatim) ? "&nbsp;" : " "); break;
                     case 34 : nwcp = 1; fprintf(fp, "&quot;"); break;
                     case 38 : nwcp = 1; fprintf(fp, "&amp;"); break;
                     case 60 : nwcp = 1; fprintf(fp, "&lt;"); break;
                     case 62 : nwcp = 1; fprintf(fp, "&gt;"); break;
                     default : if ((*t < 32) || (*t > 126))
                                  fprintf(fp, "&#%d;", *t);
                               else fprintf(fp, "%c", *t);
                               nwcp = 1;
                  }
                  t++;
               } else { t++; *t = tmp; }
            }
         }
      } else if (catcode[*c] == 2) {
         nwcp = 1;
         t = swar; do { *t = *c; t++; c++; } while (catcode[*c] == 2);
         *t = 0; tmp = findEnc(swar);
         switch (tmp) {
            case 97 : fprintf(fp, "a"); break;
            case 65 : fprintf(fp, "aA"); break;
            case 1  :
            case 105: fprintf(fp, "&#1;"); break;
            case 2  :
            case 73 : fprintf(fp, "&#2;"); break;
            case 3  :
            case 117: fprintf(fp, "&#3;"); break;
            case 4  :
            case 85 : fprintf(fp, "&#4;"); break;
            case 5  :
            case 87 : fprintf(fp, "&#5;"); break;
            case 6  :
            case 101: fprintf(fp, "&#6;"); break;
            case 7  :
            case 69 : fprintf(fp, "&#7;"); break;
            case 8  : fprintf(fp, "&#8;"); break;
            case 79 :
            case 111: fprintf(fp, "o"); break;
            case 14 : fprintf(fp, "a&#14;A"); break;
            default : fprintf(stderr, "Undefined vowel code : %s\n", swar);
         }
      } else {
         nwcp = 1;
         t = ban; do { *t = *c; t++; c++; } while (catcode[*c] == 3); *t = 0;
         t = swar; while (catcode[*c] == 2) { *t = *c; t++; c++; } *t = 0;
         if (strlen(swar) == 0) tswar = 97; else {
            tswar = findEnc(swar);
            if (tswar < 0) {
               fprintf(stderr, "Undefined vowel code : %s\n", swar);
               tswar = 97;
            }
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
         if ( ((tswar == 3) || (tswar == 117)) && (!jafala) && (!rafala) ) {
            switch (tban) {
               case 114: tban = 25; tswar = 97; break;
               case 104: tban = 27; tswar = 97; break;
               case 103: tban = 29; tswar = 97; break;
               case  83: tban = 30; tswar = 97; break;
               case 192: tban = 193; tswar = 97; break;
               case 226: tban = 227; tswar = 97; break;
               case 253: tban = 254; tswar = 97; break;
            }
         }
         if ( ((tswar == 4) || (tswar == 85)) && (tban == 114) && (!jafala) && (!rafala) ) {
            tban = 26; tswar = 97;
         }
         if ( ((tswar == 5) || (tswar == 87)) && (tban == 104) && (!jafala) && (!rafala) ) {
            tban = 28; tswar = 97;
         }
         if ((tban == 121) && (ref)) {
            tban = 114;
            jafala = 1;
            ref = 0;
         }
         if (tban < 0) {
            if ((chandra) && (strlen(t) == 0)) sprintf(ban, "w");
            else sprintf(ban, "&nbsp;%s%s%s%s", ref ? "^" : "", chandra ? "w" : "", rafala ? "&#15;" : "", jafala ? "&#14;" : "");
         } else if ((tban < 32) || (tban > 126))
            sprintf(ban, "&#%d;%s%s%s%s", tban, ref ? "^" : "", chandra ? "w" : "", rafala ? "&#15;" : "", jafala ? "&#14;" : "");
         else
            sprintf(ban, "%c%s%s%s%s", tban, ref ? "^" : "", chandra ? "w" : "", rafala ? "&#15;" : "", jafala ? "&#14;" : "");
         switch (tswar) {
            case 97 : fprintf(fp, "%s", ban); break;
            case 65 : fprintf(fp, "%sA", ban); break;
            case 1  :
            case 105: fprintf(fp, "i%s", ban); break;
            case 2  :
            case 73 : fprintf(fp, "%sI", ban); break;
            case 3  :
            case 117: fprintf(fp, "%su", ban); break;
            case 4  :
            case 85 : fprintf(fp, "%sU", ban); break;
            case 5  :
            case 87 : fprintf(fp, "%sW", ban); break;
            case 6  :
            case 101: fprintf(fp, "e%s", ban); break;
            case 7  :
            case 69 : fprintf(fp, "E%s", ban); break;
            case 8  : fprintf(fp, "e%sA", ban); break;
            case 79 :
            case 111: fprintf(fp, "e%sO", ban); break;
            case 14 : fprintf(fp, "%s&#14;A", ban); break;
         }
      }
   }
}

void btxToBng ( char *c, FILE *fp )
{
   int len, i, j, bngmode = 1, tmp, ref, rafala, jafala, chandra, tban, tswar, line, ltr;
   char ban[51], swar[11], punc[1024], *t, *tt, engtag[10000], *idx, rfstr[2], jfstr[2];

   rfstr[0] = 15; jfstr[0] = 14; rfstr[1] = jfstr[1] = 0;
   sprintf(engtag, "english : "); idx = engtag; while (*idx) idx++;
   line = 1; ltr = 0;
   len = strlen(c);
   while (*c) {
      fflush(fp);
      if (!bngmode) {
         if (*c == '#') {
            if (strncmp(c, "##", 2)) {
               bngmode = 1; c++;
               sprintf(idx, "%d.%d ", line, ltr); while (*idx) idx++;
            } else {
               ltr += fprintf(fp, "#"); c++; c++;
            }
         } else {
            if ((*c) == '\n') {
               sprintf(idx, "%d.%d ", line, ltr); while (*idx) idx++;
               fprintf(fp, "\n"); bngmode = 1; line++; ltr = 0;
            } else ltr += fprintf(fp, "%c", *c);
            c++;
         }
      } else if (*c == '#') {
         if (strncmp(c, "##", 2)) {
            bngmode = 0; c++;
            sprintf(idx, "%d.%d ", line, ltr); while (*idx) idx++;
         } else {
            ltr += fprintf(fp, "#"); c++; c++;
         }
      } else if (catcode[*c] < 2) {
         if ((catcode[*c] == 1) && (findLigEnc(c) < 0)) c++;
         else {
            t = punc;
            while ((*c != '#') && (*c != 0) && (catcode[*c] < 2)) {
               *t = findPuncEnc(c); t++; c++;
            }
            *t = 0; t = punc;
            while (strlen(t) > 0) {
               tmp = findLigEnc(t);
               if (tmp < 0) {
                  if ((*t) == '\n') {
                     fprintf(fp, "\n"); line++; ltr = 0;
                  } else ltr += fprintf(fp, "%c", *t);
                  t++;
               } else { t++; *t = tmp; }
            }
         }
      } else if (catcode[*c] == 2) {
         t = swar; do { *t = *c; t++; c++; } while (catcode[*c] == 2);
         *t = 0; tmp = findEnc(swar);
         switch (tmp) {
            case 97 : ltr += fprintf(fp, "a"); break;
            case 65 : ltr += fprintf(fp, "aA"); break;
            case 1  :
            case 105: ltr += fprintf(fp, "%c", 1); break;
            case 2  :
            case 73 : ltr += fprintf(fp, "%c", 2); break;
            case 3  :
            case 117: ltr += fprintf(fp, "%c", 3); break;
            case 4  :
            case 85 : ltr += fprintf(fp, "%c", 4); break;
            case 5  :
            case 87 : ltr += fprintf(fp, "%c", 5); break;
            case 6  :
            case 101: ltr += fprintf(fp, "%c", 6); break;
            case 7  :
            case 69 : ltr += fprintf(fp, "%c", 7); break;
            case 8  : ltr += fprintf(fp, "%c", 8); break;
            case 79 :
            case 111: ltr += fprintf(fp, "o"); break;
            case 14 : ltr += fprintf(fp, "a%cA", 14); break;
            default : fprintf(stderr, "Undefined vowel code : %s\n", swar);
         }
      } else {
         t = ban; do { *t = *c; t++; c++; } while (catcode[*c] == 3); *t = 0;
         t = swar; while (catcode[*c] == 2) { *t = *c; t++; c++; } *t = 0;
         if (strlen(swar) == 0) tswar = 97; else {
            tswar = findEnc(swar);
            if (tswar < 0) {
               fprintf(stderr, "Undefined vowel code : %s\n", swar);
               tswar = 97;
            }
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
         if ( ((tswar == 3) || (tswar == 117)) && (!jafala) && (!rafala) ) {
            switch (tban) {
               case 114: tban = 25; tswar = 97; break;
               case 104: tban = 27; tswar = 97; break;
               case 103: tban = 29; tswar = 97; break;
               case  83: tban = 30; tswar = 97; break;
               case 192: tban = 193; tswar = 97; break;
               case 226: tban = 227; tswar = 97; break;
               case 253: tban = 254; tswar = 97; break;
            }
         }
         if ( ((tswar == 4) || (tswar == 85)) && (tban == 114) && (!jafala) && (!rafala) ) {
            tban = 26; tswar = 97;
         }
         if ( ((tswar == 5) || (tswar == 87)) && (tban == 104) && (!jafala) && (!rafala) ) {
            tban = 28; tswar = 97;
         }
         if ((tban == 121) && (ref)) {
            tban = 114;
            jafala = 1;
            ref = 0;
         }
         if (tban < 0) {
            if ((chandra) && (strlen(t) == 0)) sprintf(ban, "w");
            else sprintf(ban, " %s%s%s%s", ref ? "^" : "", chandra ? "w" : "", rafala ? rfstr : "", jafala ? jfstr : "");
         } else sprintf(ban, "%c%s%s%s%s", tban, ref ? "^" : "", chandra ? "w" : "", rafala ? rfstr : "", jafala ? jfstr : "");
         switch (tswar) {
            case 97 : ltr += fprintf(fp, "%s", ban); break;
            case 65 : ltr += fprintf(fp, "%sA", ban); break;
            case 1  :
            case 105: ltr += fprintf(fp, "i%s", ban); break;
            case 2  :
            case 73 : ltr += fprintf(fp, "%sI", ban); break;
            case 3  :
            case 117: ltr += fprintf(fp, "%su", ban); break;
            case 4  :
            case 85 : ltr += fprintf(fp, "%sU", ban); break;
            case 5  :
            case 87 : ltr += fprintf(fp, "%sW", ban); break;
            case 6  :
            case 101: ltr += fprintf(fp, "e%s", ban); break;
            case 7  :
            case 69 : ltr += fprintf(fp, "E%s", ban); break;
            case 8  : ltr += fprintf(fp, "e%sA", ban); break;
            case 79 :
            case 111: ltr += fprintf(fp, "e%sO", ban); break;
            case 14 : ltr += fprintf(fp, "%s%cA", ban, 14); break;
         }
      }
   }
   fprintf(fp, "%s\n", engtag);
}

void btxToISCII ( char *c, FILE *fp )
{
   int len, i, j, bngmode = 1, tmp, ref, rafala, jafala, chandra, tban, tswar;
   char ban[51], swar[11], punc[1024], *t, *tt;
   char isciiEncTable[256][10];

   readISCIIEnc(isciiEncTable);
   len = strlen(c);
   while (*c) {
      fflush(fp);
      if (!bngmode) {
         if (*c == '#') {
            if (strncmp(c,"##",2)) bngmode = 1; else { fprintf(fp, "#"); c++; }
         } else {
            fprintf(fp, "%c", *c); if (*c == '\n') bngmode = 1;
         }
         c++;
      } else if (*c == '#') {
         if (strncmp(c,"##",2)) bngmode = 0; else { fprintf(fp, "#"); c++; }
         c++;
      } else if (catcode[*c] < 2) {
         if ((catcode[*c] == 1) && (findLigEnc(c) < 0)) c++;
         else {
            t = punc;
            while ((*c != '#') && (*c != 0) && (catcode[*c] < 2)) {
               *t = findPuncEnc(c); t++; c++;
            }
            *t = 0; t = punc;
            while (strlen(t) > 0) {
               tmp = findLigEnc(t);
               if (tmp < 0) {
                  switch (*t) {
                     case  9  : fprintf(fp, "\t"); break;
                     case 10  : fprintf(fp, "\n"); break;
                     case 32  : fprintf(fp, " "); break;
                     default  : fprintf(fp, "%s", isciiEncTable[*t]);
                  }
                  t++;
               } else { t++; *t = tmp; }
            }
         }
      } else if (catcode[*c] == 2) {
         t = swar; do { *t = *c; t++; c++; } while (catcode[*c] == 2);
         *t = 0; tmp = findEnc(swar);
         switch (tmp) {
            case 97 : fprintf(fp, "%s", isciiEncTable[97]); break;
            case 65 : fprintf(fp, "%c", 165); break;
            case 1  :
            case 105: fprintf(fp, "%s", isciiEncTable[1]); break;
            case 2  :
            case 73 : fprintf(fp, "%s", isciiEncTable[2]); break;
            case 3  :
            case 117: fprintf(fp, "%s", isciiEncTable[3]); break;
            case 4  :
            case 85 : fprintf(fp, "%s", isciiEncTable[4]); break;
            case 5  :
            case 87 : fprintf(fp, "%s", isciiEncTable[5]); break;
            case 6  :
            case 101: fprintf(fp, "%s", isciiEncTable[6]); break;
            case 7  :
            case 69 : fprintf(fp, "%s", isciiEncTable[7]); break;
            case 8  : fprintf(fp, "%s", isciiEncTable[8]); break;
            case 79 :
            case 111: fprintf(fp, "%s", isciiEncTable[111]); break;
            case 14 : fprintf(fp, "%s%s%s", isciiEncTable[97], isciiEncTable[14], isciiEncTable[65]); break;
            default : fprintf(stderr, "Undefined vowel code : %s\n", swar);
         }
      } else {
         t = ban; do { *t = *c; t++; c++; } while (catcode[*c] == 3); *t = 0;
         t = swar; while (catcode[*c] == 2) { *t = *c; t++; c++; } *t = 0;
         if (strlen(swar) == 0) tswar = 97; else {
            tswar = findEnc(swar);
            if (tswar < 0) {
               fprintf(stderr, "Undefined vowel code : %s\n", swar);
               tswar = 97;
            }
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
            else sprintf(ban, "%s %s%s", ref ? isciiEncTable[94] : "", rafala ? isciiEncTable[15] : "", jafala ? isciiEncTable[14] : "");
         } else sprintf(ban, "%s%s%s%s", ref ? isciiEncTable[94] : "", isciiEncTable[tban], rafala ? isciiEncTable[15] : "", jafala ? isciiEncTable[14] : "");
         switch (tswar) {
            case 97 : fprintf(fp, "%s", ban); break;
            case 65 : fprintf(fp, "%s%c", ban, 218); break;
            case 1  :
            case 105: fprintf(fp, "%s%c", ban, 219); break;
            case 2  :
            case 73 : fprintf(fp, "%s%c", ban, 220); break;
            case 3  :
            case 117: fprintf(fp, "%s%c", ban, 221); break;
            case 4  :
            case 85 : fprintf(fp, "%s%c", ban, 222); break;
            case 5  :
            case 87 : fprintf(fp, "%s%c", ban, 223); break;
            case 6  :
            case 101: fprintf(fp, "%s%c", ban, 225); break;
            case 7  :
            case 69 : fprintf(fp, "%s%c", ban, 226); break;
            case 8  : fprintf(fp, "%s%c", ban, 229); break;
            case 79 :
            case 111: fprintf(fp, "%s%c", ban, 230); break;
            case 14 : fprintf(fp, "%s%s%c", ban, isciiEncTable[14], 218); break;
         }
         if (chandra) fprintf(fp, "%s", isciiEncTable[119]);
      }
   }
}

void procPageSpec ( char *pagespec , int *pt, float *textht, float *xoff, float *yoff, float *pageht )
{
   int error = 0;
   char *idx = NULL;
   int tpt;
   float ttextht, txoff, tyoff, tpageht;

   if (pagespec == NULL) error = 1; else {
      idx = strchr(pagespec,',');
      if (idx == NULL) error = 1; else {
         *idx = '\0';
         tpt = (float)(atol(pagespec));
         pagespec = ++idx;

         idx = strchr(pagespec,',');
         if (idx == NULL) error = 1; else {
            *idx = '\0';
            ttextht = (float)(atof(pagespec));
            pagespec = ++idx;

            idx = strchr(pagespec,',');
            if (idx == NULL) error = 1; else {
               *idx = '\0';
               txoff = (float)(atof(pagespec));
               pagespec = ++idx;

               idx = strchr(pagespec,',');
               if (idx == NULL) error = 1; else {
                  *idx = '\0';
                  tyoff = (float)(atof(pagespec));
                  tpageht = (float)(atof(++idx));
               }
            }
         }
      }
   }
   if (error) {
      fprintf(stderr, "Error in page specifications. Using A4 paper as default.\n");
      *pt = 12;
      *textht = 24.7;
      *xoff = 2.5;
      *yoff = 2.5;
      *pageht = 29.7;
   } else {
      *pt = tpt;
      *textht = ttextht;
      *xoff = txoff;
      *yoff = tyoff;
      *pageht = tpageht;
   }
}

void btxToPS ( char *c, FILE *fp, char *pagespec )
{
   int pt;
   float textht, xoff, yoff, pageht;
   float corr1, corr2, corr3, corr4, corr5, corr6;
   float lineskip, uly, lly, curry;
   int pageno = 1;

   int len, i, j, bngmode = 1, tmp, ref, rafala, jafala, chandra, tban, tswar;
   char ban[51], swar[11], punc[1024], *t, *tt;
   char Corr15[100], Corr94[100], Corr119[100];

   procPageSpec(pagespec,&pt,&textht,&xoff,&yoff,&pageht);
   corr1 = 0.43 * (float)(pt);
   corr2 = 0.23 * (float)(pt);
   corr3 = 0.20 * (float)(pt);
   corr4 = 0.56 * (float)(pt);
   corr5 = 0.06 * (float)(pt);
   corr6 = 0.12 * (float)(pt);
   sprintf(Corr15, "%f B 15 P %f F", corr4, corr4);
   sprintf(Corr94, "%f B (^) S %f F", corr3, corr3);
   sprintf(Corr119, "%f B (w) S %f F", corr3, corr3);
   textht *= 28.35;
   xoff *= 28.35;
   yoff *= 28.35;
   pageht *= 28.35;
   lineskip = 1.4 * (float)(pt);
   uly = (pageht - yoff) - 0.8 * (float)(pt);
   lly = uly - textht;
   curry = uly;

   fprintf(fp,"/bn { /Bengali findfont %d scalefont setfont } def\n", pt);
   fprintf(fp,"/rm { /Times-Roman findfont %d scalefont setfont } def\n", pt);
   fprintf(fp,"/M { moveto } def\n");
   fprintf(fp,"/S { show } def\n");
   fprintf(fp,"/N { %f %f M } def\n", xoff, uly);
   fprintf(fp,"/B { neg 0 rmoveto } def\n/F { 0 rmoveto } def\n");
   fprintf(fp,"/CH 1 string def\n");
   fprintf(fp,"/P { CH 0 3 -1 roll put CH S } def\n");

   fprintf(fp,"%%%%Page: 1 1\nN bn\n");

   len = strlen(c);
   while (*c) {
      fflush(fp);
      if (!bngmode) {
         if (*c == '#') {
            if (strncmp(c, "##", 2)) {
               bngmode = 1; c++; fprintf(fp, "bn\n");
            } else {
               fprintf(fp, "(#) S"); c++; c++;
            }
         } else {
            switch (*c) {
               case 10 : if ( (curry -= lineskip) < lly ) {
                            pageno++;
                            fprintf(fp,"showpage\n\n%%%%Page: %d %d\nN bn\n", pageno, pageno);
                            curry = uly;
                         } else {
                            fprintf(fp,"%f %f M bn\n", xoff, curry);
                         }
                         bngmode = 1;
                         break;
               default : fprintf(fp, "%d P\n", *c);
            }
            c++;
         }
      } else if (*c == '#') {
         if (strncmp(c, "##", 2)) {
            bngmode = 0; c++; fprintf(fp, "rm\n");
         } else {
            fprintf(fp, "(#) S"); c++; c++;
         }
      } else if (catcode[*c] < 2) {
         if ((catcode[*c] == 1) && (findLigEnc(c) < 0)) c++;
         else {
            t = punc;
            while ((*c != '#') && (*c != 0) && (catcode[*c] < 2)) {
               *t = findPuncEnc(c); t++; c++;
            }
            *t = 0; t = punc;
            while (strlen(t) > 0) {
               tmp = findLigEnc(t);
               if (tmp < 0) {
                  switch (*t) {
                     case 9  : fprintf(fp, "32 P\n", t);
                     case 10 : if ( (curry -= lineskip) < lly ) {
                                  pageno++;
                                  fprintf(fp,"showpage\n\n%%%%Page: %d %d\nN bn\n", pageno, pageno);
                                  curry = uly;
                               } else {
                                  fprintf(fp,"%f %f M bn\n", xoff, curry);
                               }
                               bngmode = 1;
                               break;
                     case 44 : fprintf(fp, "%f F (,) S\n", corr6); break;
                     case 46 : fprintf(fp, "%f F (.) S\n", corr1); break;
                     default : fprintf(fp, "%d P\n", *t);
                  }
                  t++;
               } else { t++; *t = tmp; }
            }
         }
      } else if (catcode[*c] == 2) {
         t = swar; do { *t = *c; t++; c++; } while (catcode[*c] == 2);
         *t = 0; tmp = findEnc(swar);
         switch (tmp) {
            case 97 : fprintf(fp, "(a) S\n"); break;
            case 65 : fprintf(fp, "(aA) S\n"); break;
            case 1  :
            case 105: fprintf(fp, "%f B 1 P %f F\n", corr5, corr5); break;
            case 2  :
            case 73 : fprintf(fp, "2 P\n"); break;
            case 3  :
            case 117: fprintf(fp, "%f B 3 P %f F\n", corr5, corr5); break;
            case 4  :
            case 85 : fprintf(fp, "%f B 4 P %f F\n", corr5, corr5); break;
            case 5  :
            case 87 : fprintf(fp, "5 P\n"); break;
            case 6  :
            case 101: fprintf(fp, "6 P %f B\n", corr6); break;
            case 7  :
            case 69 : fprintf(fp, "7 P\n"); break;
            case 8  : fprintf(fp, "8 P\n"); break;
            case 79 :
            case 111: fprintf(fp, "(o) S\n"); break;
            case 14 : fprintf(fp, "(a) S 14 P (A) S\n"); break;
            default : fprintf(stderr, "Undefined vowel code : %s\n", swar);
         }
      } else {
         t = ban; do { *t = *c; t++; c++; } while (catcode[*c] == 3); *t = 0;
         t = swar; while (catcode[*c] == 2) { *t = *c; t++; c++; } *t = 0;
         if (strlen(swar) == 0) tswar = 97; else {
            tswar = findEnc(swar);
            if (tswar < 0) {
               fprintf(stderr, "Undefined vowel code : %s\n", swar);
               tswar = 97;
            }
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
         if ( ((tswar == 3) || (tswar == 117)) && (!jafala) && (!rafala) ) {
            switch (tban) {
               case 114: tban = 25; tswar = 97; break;
               case 104: tban = 27; tswar = 97; break;
               case 103: tban = 29; tswar = 97; break;
               case  83: tban = 30; tswar = 97; break;
               case 192: tban = 193; tswar = 97; break;
               case 226: tban = 227; tswar = 97; break;
               case 253: tban = 254; tswar = 97; break;
            }
         }
         if ( ((tswar == 4) || (tswar == 85)) && (tban == 114) && (!jafala) && (!rafala) ) {
            tban = 26; tswar = 97;
         }
         if ( ((tswar == 5) || (tswar == 87)) && (tban == 104) && (!jafala) && (!rafala) ) {
            tban = 28; tswar = 97;
         }
         if ((tban == 121) && (ref)) {
            tban = 114;
            jafala = 1;
            ref = 0;
         }
         if (tban < 0) {
            if ((chandra) && (strlen(t) == 0)) sprintf(ban, "(w) S");
            else sprintf(ban, "( ) S %s %s %s %s", ref ? Corr94 : "", chandra ? Corr119 : "", rafala ? Corr15 : "", jafala ? "14 P" : "");
         } else if (tban == 29) {
            sprintf(ban, "29 P %f B %s %s %s %s", corr5, ref ? Corr94 : "", chandra ? Corr119 : "", rafala ? Corr15 : "", jafala ? "14 P" : "");
         } else if (tban == 66) {
            sprintf(ban, "%f F (B) S %f B %s %s %s %s", corr6, corr5, ref ? Corr94 : "", chandra ? Corr119 : "", rafala ? Corr15 : "", jafala ? "14 P" : "");
         } else if (tban == 77) {
            sprintf(ban, "%f F (M) S %f B %s %s %s %s", corr6, corr6, ref ? Corr94 : "", chandra ? Corr119 : "", rafala ? Corr15 : "", jafala ? "14 P" : "");
         } else if (tban == 84) {
            sprintf(ban, "%f B (T) S %f F %s %s %s %s", corr5, corr5, ref ? Corr94 : "", chandra ? Corr119 : "", rafala ? Corr15 : "", jafala ? "14 P" : "");
         } else {
            sprintf(ban, "%d P %s %s %s %s", tban, ref ? Corr94 : "", chandra ? Corr119 : "", rafala ? Corr15 : "", jafala ? "14 P" : "");
         }
         switch (tswar) {
            case 97 : fprintf(fp, "%s\n", ban); break;
            case 65 : fprintf(fp, "%s (A) S\n", ban); break;
            case 1  :
            case 105: fprintf(fp, "(i) S %s\n", ban); break;
            case 2  :
            case 73 : fprintf(fp, "%s %f B (I) S %f F\n", ban, corr1, corr1); break;
            case 3  :
            case 117: fprintf(fp, "%s %f B (u) S %f F\n", ban, corr2, corr2); break;
            case 4  :
            case 85 : fprintf(fp, "%s %f B (U) S %f F\n", ban, corr2, corr2); break;
            case 5  :
            case 87 : fprintf(fp, "%s %f B (W) S %f F\n", ban, corr2, corr2); break;
            case 6  :
            case 101: fprintf(fp, "(e) S %s\n", ban); break;
            case 7  :
            case 69 : fprintf(fp, "(E) S %s\n", ban); break;
            case 8  : fprintf(fp, "(e) S %s (A) S\n", ban); break;
            case 79 :
            case 111: fprintf(fp, "(e) S %s %f B (O) S %f F\n", ban, corr1, corr1); break;
            case 14 : fprintf(fp, "%s 14 P (A) S\n", ban); break;
         }
      }
   }
   fprintf(fp, "showpage\n");
   fprintf(fp, "%%%%Trailer\n%%%%Pages: %d\n%%%%EOF\n", pageno);
}

int fileSize ( FILE *fp )
{
   int n = 0;
   char c;

   if (fp == NULL) {
      fprintf(stderr, "bwconv: Unable to access file\n");
      return (0);
   }
   while (!feof(fp)) {
      fscanf(fp, "%c", &c);
      n++;
   }
   return(n);
}

void readFile ( char *fname , char **input )
{
   FILE *fp;
   char *last, ch;
   int i, len;

   fp = fopen(fname, "r");
   if (fp == NULL) {
      fprintf(stderr, "bwconv: Input file \"%s\" not found\n", fname);
      exit(3);
   }
   len = fileSize(fp);
   fseek(fp, 0, SEEK_SET);
   *input = (char *)malloc((len + 1) * sizeof(char));
   last = *input;
   for (i=0; i<len; i++) {
      fscanf(fp, "%c", &ch);
      *last = ch;
      last++;
   }
   *last = '\0';
   fclose(fp);
}

void helpMsg ( )
{
   fprintf(stderr, "Usage: bwconv <conversion_options> <input_file> [<encoding_file>]\n");
   fprintf(stderr, "Here <conversion_options> is <format_option>[<modifiers>]\n");
   fprintf(stderr, "The format options are:\n");
   fprintf(stderr, "   b   Bengali -> Trans          B   Trans -> Bengali\n");
   fprintf(stderr, "   i   Bengali -> ISCII          I   Trans -> ISCII\n");
   fprintf(stderr, "   l   Bengali -> LaTeX          L   Trans -> LaTeX\n");
   fprintf(stderr, "   m   Bengali -> HTML           M   Trans -> HTML\n");
   fprintf(stderr, "   p   Bengali -> PostScript     P   Trans -> PostScript\n");
   fprintf(stderr, "   s   ISCII   -> Bengali        S   ISCII -> Trans\n");
   fprintf(stderr, "The modifiers are:\n");
   fprintf(stderr, "   s   Read text from command line (for B, I, L, M and P only)\n");
   fprintf(stderr, "   n   Output named characters (for l and L only)\n");
   fprintf(stderr, "   v   Convert text in verbatim mode (for l, L, m and M only)\n");
   fprintf(stderr, "   +   point,textheight,xoffset,yoffset,pageheight (for p and P only)\n");
   fprintf(stderr, "One of the conversion options and an input file name or string is mandatory.\n");
   fprintf(stderr, "Other (conversion?) options include:\n");
   fprintf(stderr, "   h   Display help message and quit\n");
   fprintf(stderr, "   v   Display Version info and quit\n");
   fprintf(stderr, "Examples:\n");
   fprintf(stderr, "bwconv i file1.bng\n");
   fprintf(stderr, "   Convert Bengali text file file1.bng to ISCII file file1.isc\n");
   fprintf(stderr, "bwconv Lns \"eTi ek_Ti bAkya\"\n");
   fprintf(stderr, "   Convert the Roman text \"eTi ek_Ti bAkya\" to LaTeX.\n");
}

void versionInfo ( )
{
   fprintf(stderr, "Version 1.0 (June 2002)\nAuthor: Abhijit Das (Barda) [ad_rab@yahoo.com]\n");
}

void procCmdLine ( int argc , char *argv[] )
{
   char task = '?', *input = NULL, fname[100], encfname[1024], pagespec[128], *argv1 = NULL;
   FILE *fp = NULL;
   int printMode = 0, verbatim = 0;

   if (argc == 1) {
      fprintf(stderr, "bwconv: Too few arguments\n");
      fprintf(stderr, "Type \"bwconv h\" for command line options\n");
      exit(1);
   }

   if (argv[1][0] == '-') argv[1]++;
   task = argv[1][0];

   if (task == 'h') { helpMsg(); exit(-1); }
   if (task == 'v') { versionInfo(); exit(-2); }

   if (argc == 2) {
      fprintf(stderr, "bwconv: Too few arguments\n");
      fprintf(stderr, "Type \"bwconv h\" for command line options\n");
      exit(1);
   }

   switch (task) {
      case 'b' :
      case 'i' :
      case 'l' :
      case 'm' :
      case 'p' :
      case 's' :
      case 'S' : fprintf(stderr, "This conversion option is not implemented yet.\n");
                 exit(0);
      case 'B' : if ((strlen(argv[1]) > 1) && (argv[1][1] == 's')) {
                    input = (char *)malloc((strlen(argv[2]) + 2) * sizeof(char));
                    sprintf(input, "%s\n", argv[2]);
                 }
                 break;
      case 'I' : if ((strlen(argv[1]) > 1) && (argv[1][1] == 's')) {
                    input = (char *)malloc((strlen(argv[2]) + 2) * sizeof(char));
                    sprintf(input, "%s\n", argv[2]);
                 }
                 break;
      case 'L' : if ((strlen(argv[1]) > 1) && (argv[1][1] == 's')) {
                    input = (char *)malloc((strlen(argv[2]) + 2) * sizeof(char));
                    sprintf(input, "%s\n", argv[2]);
                 }
                 if ((strlen(argv[1]) > 1) && (argv[1][1] == 'n')) printMode = 1;
                 if ((strlen(argv[1]) > 1) && (argv[1][1] == 'v')) verbatim = 1;
                 if ((strlen(argv[1]) > 2) && (argv[1][2] == 's')) {
                    input = (char *)malloc((strlen(argv[2]) + 2) * sizeof(char));
                    sprintf(input, "%s\n", argv[2]);
                 }
                 if ((strlen(argv[1]) > 2) && (argv[1][2] == 'n')) printMode = 1;
                 if ((strlen(argv[1]) > 2) && (argv[1][2] == 'v')) verbatim = 1;
                 if ((strlen(argv[1]) > 3) && (argv[1][3] == 's')) {
                    input = (char *)malloc((strlen(argv[2]) + 2) * sizeof(char));
                    sprintf(input, "%s\n", argv[2]);
                 }
                 if ((strlen(argv[1]) > 3) && (argv[1][3] == 'n')) printMode = 1;
                 if ((strlen(argv[1]) > 3) && (argv[1][3] == 'v')) verbatim = 1;
                 break;
      case 'M' : if ((strlen(argv[1]) > 1) && (argv[1][1] == 's')) {
                    input = (char *)malloc((strlen(argv[2]) + 2) * sizeof(char));
                    sprintf(input, "%s\n", argv[2]);
                 }
                 if ((strlen(argv[1]) > 1) && (argv[1][1] == 'v')) verbatim = 1;
                 if ((strlen(argv[1]) > 2) && (argv[1][2] == 's')) {
                    input = (char *)malloc((strlen(argv[2]) + 2) * sizeof(char));
                    sprintf(input, "%s\n", argv[2]);
                 }
                 if ((strlen(argv[1]) > 2) && (argv[1][2] == 'v')) verbatim = 1;
                 break;
      case 'P' : strcpy(pagespec,"12,24.7,2.5,2.5,29.7");
                 if (strlen(argv[1]) > 1) {
                    if (argv[1][1] == 's') {
                       input = (char *)malloc((strlen(argv[2]) + 2) * sizeof(char));
                       sprintf(input, "%s\n", argv[2]);
                       argv1 = &argv[1][2];
                    } else { argv1 = &argv[1][1]; }
                    if ( (strlen(argv1) > 1) && (argv1[0] == '+') ) {
                       argv1++;
                       strcpy(pagespec,argv1);
                    }
                 }
                 break;
      default  : fprintf(stderr, "bwconv: Unknown conversion option\n");
                 fprintf(stderr, "Type \"bwconv h\" for command line options\n");
                 exit(2);
   }

   if (input == NULL) readFile(argv[2], &input);
   fp = stdout;
   if (argc == 3) strcpy(encfname, ENCFILE); else strcpy(encfname, argv[3]);

   switch (task) {
      case 'b' : break;
      case 'i' : break;
      case 'l' : break;
      case 'm' : break;
      case 'p' : break;
      case 's' : break;
      case 'B' : initEnc(encfname); btxToBng(input, fp); break;
      case 'I' : initEnc(encfname); btxToISCII(input, fp); break;
      case 'L' : initEnc(encfname); btxToLaTeX(input, fp, printMode, verbatim); break;
      case 'M' : initEnc(encfname); btxToHTML(input, fp, verbatim); break;
      case 'P' : initEnc(encfname); btxToPS(input, fp, pagespec); break;
      case 'S' : break;
   }
}

int main ( int argc, char *argv[] )
{
   procCmdLine(argc, argv);
   exit(0);
}

/* End of bwconv.c */
