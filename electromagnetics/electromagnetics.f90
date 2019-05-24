
    program ElectroMagnetics
    use ConfigureFileModule
    use CommandLine
    use CommandInterpreter
    implicit none
    character(256), dimension(:), allocatable :: commands
    
    !type(ConfigureFile) config
    !config = init_ConfigureFile(20, "Config.txt", 21)
    
    commands = GetCommandLine(0)
    
    CALL StartCommandInterpreter(commands)
    
    end program ElectroMagnetics

