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
    
    end module