#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Jumps with cursor to given timecode,
entered TC is interpreted from right side,
period, comma or semicolon can be also used as delimiter,
zeros are automatically filled-in.

Version 0.2 - 05.08.2020

This project was developed by @msmucr
(version 0.1 - 13:42 5.6.2014)
and taken from the page:
https://forums.cockos.com/showthread.php?t=141197
'''


def msg(obj):
	RPR_ShowConsoleMsg(str(obj) + "\n")

def decode_tc(input_s):
	invalid_tc = False
	
	ttbl = str.maketrans(",.;",":::")
	tc = input_s.translate(ttbl).split(":")
	tc = [ i.zfill(1) for i in tc ]
	while len(tc) < 4:
		tc.insert(0,"0")

	for i in tc:
		if not i.isdigit():
			msg(input_s + " is not valid timecode!")
			invalid_tc = True
			break

	if not invalid_tc:
		tc_str = "{}:{}:{}:{}".format(tc[0], tc[1], tc[2], tc[3])
		return RPR_parse_timestr_pos(tc_str, 5)
	else:
		return False
		
user_input = RPR_GetUserInputs("Jump to timecode", 1, "Timecode", "", 20)

if user_input[0] == 1:
	input_tc = user_input[4]
	new_pos = decode_tc(input_tc)
	
	if new_pos != False:
		if input_tc.startswith(("+", "-")):
			# relative
			if input_tc[0] == "-":
				multiplier = -1
			else:
				multiplier = 1     
			RPR_MoveEditCursor(new_pos * multiplier, False)
		else:
			# absolute
			RPR_SetEditCurPos(new_pos, True, True)
