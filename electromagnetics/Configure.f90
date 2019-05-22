    module ConfigureModule
    use FileDataModule
    implicit none
    
    type Configure
        integer :: inputfd, outputfd
        ! character, allocatable :: inputpath, outputpath
    end type
    
    contains
    
    type(Configure) function init_Configure(fd, path, startfd) result(config)
        implicit none
        integer, intent(in) :: fd, startfd
        character(*), intent(in) :: path
        
        type(FileData) file
        character(256) path
        integer nowfd
        integer i
        
        nowfd = startfd
        file = init_FileData(fd, path)
        
        do i = 1, file%numof_lines
            if (INDEX(file%lines(i), "InputFile:") > 0) then
                ! config%inputpath = ADJUSTL(file%lines(11:))
                config%inputfd = nowfd
                nowfd = nowfd + 1
            else if (INDEX(file%lines(i), "OutputFile:") > 0) then
                ! config%outputpath = ADJUSTL(file%lines(12:))
                config%outputfd = nowfd
                nowfd = nowfd + 1
            end if
            
            
        end do
        
    end function
    
    end module