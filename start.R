
#confirm versions greater than (node 8.4.0 and npm 5.3)
nodeVersion <- system("node -v", intern=TRUE)
npmVersion <- system("npm -v", intern=TRUE)

#if node not available, notify to install node and npm globally 

#npm i –g electron-packager
electronPackagerVersion <- system("npm list -g electron-packager", intern=TRUE)

#confirm git is installed and available
gitVersion <- system("git --version", intern=TRUE)

#if git not available, notify to install git

#git clone electron-shiny sample app
system("git clone https://github.com/ColumbusCollaboratory/electron-quick-start")

#copy app.R and all files
subDir <- "temp"

if (!file.exists(subDir)){
  dir.create(file.path(subDir))
}
unlink("temp/*")

file.copy(from=list.files('.', "*.R"), to="./electron-quick-start", 
          overwrite=TRUE, recursive=TRUE, copy.mode=TRUE)

#Run R Portable for platform you are on.  Install packages needed for Shiny app
setwd("./electorn-quick-start/R-Portable-Mac")
system("R")
#npm install

#npm start


#??????  How to run install of packages for Windows if you are on a Mac.

#Run your R Project on Windows and use the Add-In to Install packages need for Shiny app



