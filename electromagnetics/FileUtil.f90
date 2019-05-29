    module FileUtil
    implicit none
    contains
    
    ! ファイルの存在を確認する
    subroutine Exists(path)
        implicit none
        character*(*), intent(in) :: path
        logical exists_status
        
        ! ファイルが存在しない場合はエラーで落とす
        inquire(file=path, exist=exists_status)
        if (exists_status == .FALSE.) then
            PRINT *, "File not found: ", path
            STOP
        end if
        
	end subroutine
    
	! 有効なFDを探索する
	integer function ScanValidFD(infd) result(scan)
		implicit none
		integer, intent(in) :: infd
		
		integer fd
        logical opened_status
        
		fd = infd
		
		do
            ! FDが既に使用済みかどうか調査する
            inquire(unit=fd, opened=opened_status)
			if (opened_status == .FALSE.) then
				scan = fd
				goto 100	! 開いていなかったら抜ける
			end if
			fd = fd + 1
		end do
100		continue
	end function
	
    end module