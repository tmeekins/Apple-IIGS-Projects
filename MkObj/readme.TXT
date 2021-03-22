MKOBJ 1.1
Copyright (c) 1993 by Tim Meekins


This program takes in GS/OS file and places it into an OMF file which can
be directly linked into a program. For example, mkobj can be used for adding
pictures, compressed data, sounds, and other "binary"-like images into
your programs that you write.

mkobj is invoked with the following syntax:

  mkobj <segment name> <input file> <output file> [<load segment>]

where....

  <segment name>: this is the name of the segment and would be the label by
  which you can access your data by. Note, if your using the Orca/M assembler,
  be sure to either type this in UPPER CASE or use the 'case off' directive
  when accessing your data.

  <input file>: this is the file which will be converted to be included in
  your application.

  <output file>: this is the generated object file created by mkobj which can
  be directly linked into your application.

  <load segment>: this is an [optional] argument. If it is specified, it sets
  the name of the load segment to place the data into. If none is given, it
  is set to the standard blank default load segment.

Have fun!

