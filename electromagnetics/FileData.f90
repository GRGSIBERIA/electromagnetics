    module FileDataModule
        implicit none
    
        type FileData
            integer :: fd, size, numof_lines
            character(160), dimension(:), allocatable :: lines
        end type
        
    contains
    
    type(FileData) function init_FileData(fd, path) result(file)
        use FileUtil
        implicit none
        integer, intent(in) :: fd
        character(*), intent(in) :: path
        
        character(1024) stream
        integer i
        
        ! ファイルを開く前に存在を確認する        
        file%numof_lines = 0
        CALL Exists(path)
        
        ! ファイルサイズだけ調べてファイルを開く
        inquire(file=path, size=file%size)
        OPEN(fd, file=path, status="old", blocksize=file%size)
        
        ! 行数をカウントする
        do
            READ (fd, "(A)", end=100), stream
            file%numof_lines = file%numof_lines + 1
        end do
100     continue
        
        ALLOCATE(file%lines(file%numof_lines))
        REWIND(fd)
        
        ! データを代入する
        do i = 1, file%numof_lines
            READ (fd, "(A)"), file%lines(i)
        end do
        
        CLOSE(fd)
    end function
    
    subroutine final_FileData(file)
        implicit none
        type(FileData) file
        
        DEALLOCATE (file%lines)
    end subroutine
        
    end module