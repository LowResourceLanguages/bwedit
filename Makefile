# Makefile for installing BWEDIT

############################################################################
# Copyright (C) 1998-2002 by Abhijit Das [ad_rab@yahoo.com]
# 
# This file is part of BWEDIT.
# 
# BWEDIT is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# BWEDIT is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with BWEDIT; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
############################################################################

SHELL = /bin/sh
CC = gcc

# Edit the following two variable settings if you want to
# install the library and the executible elsewhere

# Install directory of BWEDIT
INSTALL_DIR = /usr/local/bwedit

# Directory for installing symbolic link to bwedit
BIN_DIR = /usr/local/bin

# Directory for installing bwedit manpage
MAN_DIR = /usr/local/man/man1

# Don't edit after this line

SCRIPT_DIR = $(INSTALL_DIR)/bin
LIB_DIR = $(INSTALL_DIR)/lib
IMG_DIR = $(INSTALL_DIR)/images
HELP_DIR = $(INSTALL_DIR)/help
DEMO_DIR = $(INSTALL_DIR)/examples

all:
	@echo "Welcome to the BWEDIT installation process."
	@echo
	@echo "First go to the BDF directory and install the BDF fonts."
	@echo
	@echo "Now decide a directory where you like to install bwedit. The default"
	@echo "is /usr/local/bwedit. You need root permission for writing in this"
	@echo "default installation area. If you do not have root permission, choose"
	@echo "a directory in your home area, say, /home/<username>/bwedit and"
	@echo "incorporate the following changes manually:"
	@echo
	@echo "Edit Makefile: Change INSTALL_DIR, BIN_DIR and MAN_DIR. Do NOT change"
	@echo "change SCRIPT_DIR, LIB_DIR, IMG_DIR, HELP_DIR and DEMO_DIR."
	@echo
	@echo "Edit src/bwedit: Change installdir (Line 42). Also change newTclTk to 0,"
	@echo "if you have version 8.0 or earlier of Tcl/Tk."
	@echo
	@echo "Edit src/bwconv.c and src/bwspell.c: Change ENCFILE, BWTIENCFILE, ISCIIENCFILE,"
	@echo "DICTFILE and CASEFILE (Lines 43-46) in both of them. These files must have names"
	@echo "bn.enc, bwti.enc, iscii.enc, bw.dct and bw.cse and must reside in the directory"
	@echo "<INSTALL_DIR>/lib."
	@echo
	@echo "Now type \"make install\" at the shell prompt. Type \"make installman\" for"
	@echo "installing the bwedit man page. That's all!"

install:
	@echo "Compiling the exporter program bwconv.c ..."
	$(CC) ./src/bwconv.c -o ./src/bwconv
	@echo "Done."
	@echo "Compiling the spell checher program bwspell.c ..."
	$(CC) ./src/bwspell.c -o ./src/bwspell
	@echo "Done."
	@echo "Installing ..."
	@-mkdir $(INSTALL_DIR)
	@-mkdir $(SCRIPT_DIR) $(LIB_DIR) $(IMG_DIR) $(HELP_DIR) $(DEMO_DIR)
	@cp src/bwedit $(SCRIPT_DIR)
	@cp src/*.tcl $(SCRIPT_DIR)
	@cp src/bwconv $(SCRIPT_DIR)
	@cp src/bwspell $(SCRIPT_DIR)
	@chmod 755 $(SCRIPT_DIR)/bwedit $(SCRIPT_DIR)/bwconv $(SCRIPT_DIR)/bwspell
	@chmod 644 $(SCRIPT_DIR)/*.tcl
	@-rm $(BIN_DIR)/bwedit
	@ln -s $(SCRIPT_DIR)/bwedit $(BIN_DIR)/bwedit
	@-rm $(BIN_DIR)/bwconv
	@ln -s $(SCRIPT_DIR)/bwconv $(BIN_DIR)/bwconv
	@-rm $(BIN_DIR)/bwspell
	@ln -s $(SCRIPT_DIR)/bwspell $(BIN_DIR)/bwspell
	@cp lib/* $(LIB_DIR)
	@cp images/* $(IMG_DIR)
	@cp help/* $(HELP_DIR)
	@cp examples/* $(DEMO_DIR)
	@echo "... Installation complete."

installman:
	@cp bwedit.1 $(MAN_DIR)

