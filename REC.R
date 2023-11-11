
script_path <- rstudioapi::getActiveProject()

# load required packages
print("load packages")
print(Sys.time())
source(paste(script_path,"code/01_packages.R",sep = "/"))

# initialise connections and variables
print("initialise")
print(Sys.time())
source(paste(script_path,"code/02_initialise.R",sep = "/"))

# extract data from source
print("extract data")
print(Sys.time())
source(paste(script_path,"code/03_extract_data.R",sep = "/"))

# configure user interface
print("user interface")
print(Sys.time())
source(paste(script_path,"code/04_user_interface.R",sep = "/"))

# configure back-end or application
print("server")
print(Sys.time())
source(paste(script_path,"code/05_server.R",sep = "/"))

# setup shiny application
shiny_app <- shinyApp(ui = ui, server = server )

# run shiny application
runApp(shiny_app)
