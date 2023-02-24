#!/usr/bin/bash

echo "Content-type: text/html"
echo ""
USER=$(pwd | cut -d\/ -f3)

cat header.txt
echo "<center><h1>Hello $USER from CGI</h1></center>"
echo "<p>This was generated using a process called the \"Common Gateway Interface.\""
echo "This is an interface between the computer <i>\`server\`</i> that is serving the website content,"
echo "and the programs running on that computer.</p>"
echo "<img src=\"../img/cgi.png\" alt=\"Common Gateway Interface Logo\" title=\"Common Gatway Interface\" />"

echo "<br /><br />"
echo "<p><a href=\"https://en.wikipedia.org/wiki/Common_Gateway_Interface\">CGI</a> was inititally designed to be used for interraction between the server and client(your computer) "
echo "as a way for the client to be able to return data to the server.</p>"
echo "<p>Programmers quickly found it was an easy way to generate all the web content dynamically to save on rewriting static web content</p>"
echo "<br />"
echo "<p>This content was generated using the <a href=\"https://en.wikipedia.org/wiki/Bash_(Unix_shell)\"><i>\`bash\`</i></a> scripting language. <i>\`bash\`</i>, the 'Bourne Again Shell', is an interractive shell and scripting language for the Unix operating system. This shell has been ported to run on virtually every modern operating system, and runs as a component of many of the servers that run the internet today.</p>"
echo "<p>Any programming language can be used to generate a cgi as long as the server knows how to execute the resulting file, and the formatting is correct for outputting to the HTTP stream.</p>"
echo "<p>Contents of file hello_c.c</p>"
echo "<pre>"
cat hello_c.c | sed 's/</\&lt;/' | sed 's/>/\&gt;/'
echo "</pre>"
echo "<p>this was compiled with \`gcc hello_c.c -o hello_c\` then executed from in the bash script with ./hello_c</p>"
./hello_c
cat footer.txt
