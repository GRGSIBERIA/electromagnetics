    module HistoryFileModule
    implicit none
    
    type HistoryData
        integer numof_time, maxid
        double precision, dimension(:,:,:), allocatable :: displacement
    end type
    
    contains
    
    type(HistoryData) function init_HistoryData(path) result(history)
        use FileDataModule
        use FileUtil
        implicit none
        character*(*), intent(in) :: path
        integer fd, i, element_count, nodeid, num, timeid
        double precision x, y, z
        character*16 tmp
        type(FileData) file
        
        fd = ScanValidFD(20)
        file = init_FileData(fd, path)
        element_count = 0
        
        ! 前提となるデータを読み込む
        do i = 1, file%numof_lines
            if (INDEX(file%lines(i), "*Times") > 0) then
                READ (file%lines(i), *) tmp, history%numof_time
                element_count = element_count + 1
            else if (INDEX(file%lines(i), "*NumNode") > 0) then
                READ (file%lines(i), *) tmp, history%maxid
                element_count = element_count + 1
            end if
            
            if (element_count >= 2) then
                goto 100
            end if
        end do
100     continue
        
        ALLOCATE (history%displacement(3, history%numof_time, history%maxid))
        history%displacement = 0.0d0
    
        ! 各ノードの読み込み
        i = i + 1
        do
            READ (file%lines(i), *, end=300) tmp, nodeid
            if (INDEX(tmp, "*Node") <= 0) then
                goto 200
            end if
            
            i = i + 1
            do timeid = 1, history%numof_time
                READ (file%lines(num), *, end=300) history%displacement(:, timeid, nodeid)
                i = i + 1
            end do
            
        end do
        goto 300
        
200     continue
        PRINT *, "ERROR: LINE ", i
        PRINT *, "INVALID ELEMENT NAME - ", tmp
        STOP
        
300     continue        
        CALL final_FileData(file)
    end function
    
    end module