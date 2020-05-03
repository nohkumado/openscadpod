# openscadpod
a very simple POD parser for openscad files
can parse recursively a directory and extracts the POD info in the files
perl pod syntx check perldoc perlpod 
or just use the 
=pod start parsing
=head[1-4]  heading
=over start a list
=item  list item
=back  stop list
=cut stop parsing

the output is written under html/name.html files, if recursive an index.html is written
