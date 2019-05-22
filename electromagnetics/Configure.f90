    module ConfigureModule
    use FileDataModule
    implicit none
    
    type Configure
        
    end type
    
    contains
    
    type(Configure) function init_Configure(fd, path) result(conf)
        implicit none
        integer, intent(in) :: fd
        character(*), intent(in) :: path
        
        type(FileData) file
        
        file = init_FileData(fd, path)
    end function
    
    end module