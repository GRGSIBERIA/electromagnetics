    module PartFileModule
    implicit none
    
    type PartData
        integer :: time_count, 
        double precision, dimension(:,:), allocatable :: positiions
        integer, dimension(:,:), allocatable :: elements
    end type
    
    contains
    
    type(PartData) function init_PartData(path) result(part)
        USE FileUtil
        implicit none
        character*(*), intent(in) path
        
        integer fd
        
        CALL Exists(path)
        fd = ScanValidFD(fd)
        
        ! ë±Ç´ÇÕñæì˙ÅI
        
    end function
    
    end module