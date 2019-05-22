    module FileDataModule
        implicit none
    
        type FileData
            integer :: fd, size, numofLines, maxLength
            character, dimension(:,:), allocatable :: lines
        end type
        
    contains
    
    type(FileData) function init_FileData(fd, path) result(file)
        implicit none
        integer, intent(in) :: fd
        character*(*), intent(in) :: path
        
        logical exists_status
        character, dimension(:), allocatable :: stream
        
        ! ファイルを開く前に存在を確認する        
        file%fd = fd
        inquire(file=path, exist=exists_status)
        if (exists_status == .FALSE.) then
            PRINT *, "File not found: ", path
            STOP
        end if
        
        
        OPEN(fd, file=path, status="old")
        inquire(fd, size=file%size)
        
        CLOSE(fd)
    end function
        
    end module