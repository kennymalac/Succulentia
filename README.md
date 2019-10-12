# Succulentia
[Ludum Dare 45 entry](https://ldjam.com/events/ludum-dare/45/$168872)

Start with nothing but an empty pot in your dry garden. Plant, water, and grow healthy succulent plants while clicking away at pesky bugs that are trying to invade your garden and damage your precious plants.
  
## Build instructions
First, you will need a working Nim installation. We are using version 1.0.0 but choosenim makes it easy to change versions. Download the official choosenim binary [from their site](https://nim-lang.org/) so that you have the latest version even if it is not the latest version in your repository (assuming you use GNU/Linux). If you are using Windows or Mac, there are instructions on how to install Nim on the site as well.
  
Subsequently, install SFML and CSFML development headers.
[SFML](https://www.sfml-dev.org/index.php)
[CSFML](https://www.sfml-dev.org/download/csfml/)
These should be available in your repos (on GNU/Linux). For Windows, you'll want to throw most of the DLLs into the directory where the executable is built.

Next, you are ready to build once nimble is installed. Simply run "nimble build" alongside Succulentia.nimble and you should be ready to go! Run the executable in the same directory.
