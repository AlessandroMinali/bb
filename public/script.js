setInterval ("doSomething()", 200);
// setTimeout ("setup()", 1000);

// function setup() {
// 	var el = document.getElementById("ignore");
// 	el.addEventListener("click", hidePrompt, false);
// }

function hidePrompt() {
	banner = document.getElementsByTagName("header");
	banner[0].style.display = "none";
}

function getElementsByTagNames(elements) {
  elements = elements.split(",");
  var foundElements = [];
  var j;
  for(var j = 0; j< elements.length; j++) {
    foundElements.push(document.getElementsByTagName(elements[j]));
  }
  return foundElements;
}

function doSomething() {
	var width = document.body.clientWidth
	copy = document.getElementById("copy");
	copy.style.display = "";
	version = document.getElementById("version");
	version.style.display = "";
	var x = 3

	if (width <= 960) {
		x = 2;
	} 
	if (width < 700) {
		x = 1	;
		copy.style.display = "none";
		version.style.display = "none";
	}

	var items = getElementsByTagNames("canvas,div,video");
	var i; var j;

	//live banner
	// banner = document.getElementsByTagName("header");
	// banner[0].style.left = (width/2 - 100	) + "px";

	for (i = 0; i < items.length; i++) {
		for (j = 0; j < items[i].length; j++) {
			items[i][j].style.width = String(width/x - 3) + "px";
			items[i][j].style.height = String(width/x/1.77777777777778 - 0) + "px";
		}
	}
}


