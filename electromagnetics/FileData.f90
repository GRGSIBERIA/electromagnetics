    module FileDataModule
        implicit none
    
        type FileData
            integer :: fd, size, numof_lines, max_length
            character, dimension(:,:), allocatable :: lines
        end type
        
    contains
    
    type(FileData) function init_FileData(fd, path) result(file)
        use FileUtil
        implicit none
        integer, intent(in) :: fd
        character(*), intent(in) :: path
        
        character(1024) stream
        integer count, word
        
        ! ファイルを開く前に存在を確認する        
        file%fd = fd
        file%numof_lines = 0
        file%max_length = 0
        CALL Exists(path)
        
        ! ファイルサイズだけ調べてファイルを開く
        inquire(file=path, size=file%size)
        OPEN(fd, file=path, status="old", blocksize=1024, buffercount=1024)
        
        ! 行数をカウントする
        do
            READ (fd, "(A)", end=100), stream
            
            if (file%max_length < len_trim(stream)) then
                file%max_length = len_trim(stream)
            end if
            
            file%numof_lines = file%numof_lines + 1
        end do
100     continue
        
        ! 行の長さと行数に対応したデータを確保
        ALLOCATE(file%lines(file%max_length, file%numof_lines))
        REWIND(file%fd)
        
        ! ファイルから読み取って突っ込む
        count = 1
        do
            READ (fd, "(A)", end=200), stream
            
            ! streamの文字列を行データに転送する
            do word = 1, file%max_length
                file%lines(word,count) = stream(word:word)
            end do
            
            count = count + 1
        end do
200     continue        
        
        CLOSE(fd)
    end function
        
    end module