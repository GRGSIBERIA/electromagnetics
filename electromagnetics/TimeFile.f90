    module TimeFileModule
    implicit none
    
    type TimeData
        integer :: count
        double precision, dimension(:), allocatable :: times
    end type
    
    contains
    
    type(TimeData) function init_TimeData(path) result(time)
        use FileUtil
        implicit none
        
        character*(*), intent(in) :: path
        
        integer fd, i
        character(256) line
        
        ! 単一ファイルで使いまわしはしないのでさっさと開く
        CALL Exists(path)
        fd = ScanValidFD(20)
        
        OPEN (fd, file=path, status="old")
        
        ! 時間の行数を確認する
        time%count = 0
        
        do
            READ (fd, "(A)", end=100) line
            time%count = time%count + 1
        end do
100     continue        
        
        ! 時間の領域を確保してファイルからデータを読み込む
        ALLOCATE (time%times(time%count))
        REWIND (fd)
        do i = 1, 
            READ (fd, *) time%times(i)
        end do
        
        CLOSE (fd)
    end function
    
    end module