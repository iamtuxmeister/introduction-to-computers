//                  .|'''.|                      .
//                  ||..  '  .... ... .. ...   .||.   ....   ... ...
//                   ''|||.   '|.  |   ||  ||   ||   '' .||   '|..'
//                 .     '||   '|.|    ||  ||   ||   .|' ||    .|.
//                 |'....|'     '|    .||. ||.  '|.' '|..'|' .|  ||.
//                           .. |
//                            ''


// strings can be operated on
"Hello, " + "World!"; // => "Hello, World!"
"1, 2, " + 3; // => "1, 2, 3"

// create functions that do stuff;

function doStuff() {
    return "Stuff is done";
}

doStuff(); // => "Stuff is done"

//Variables and constants hold values
var thisWillChange = 9;
const thisWontChange = "Your mom";

// Conditional branching
if (thisWontChange === "Your mom") {
    console.log("Hi mom!");
} else {
    console.log("You're not my mom!");
}
