    module NodeDataModule
    
    type :: NodeData
    	integer, dimension(:,:), allocatable :: nodeids             ! 要素節点番号
        double precision, dimension(:,:), allocatable :: vertices   ! 節点座標
    end type NodeData
    
    contains
    
    ! *Element要素を探す
    subroutine SearchElement(fd)
        implicit none
        integer, intent(in) :: fd
        character(256) line
        
        do
            READ (fd, "(A)", end=100) line
            if (INDEX(line, "*Element") > 0) then
                goto 100
            end if
        end do
100     continue
    end subroutine
    
    ! 要素節点数を数える
    ! 空行も数えるので仕様として空行を入れてはならない
    integer function CountElement(fd) result(count)
        implicit none
        integer, intent(in) :: fd
        character(256) line
        
        count = 0
        do
            READ (fd, "(A)", end=200) line
            if (INDEX(line, "*") > 0) then
                goto 200
            end if
            count = count + 1
        end do
200     continue        
        
    end function
    
    ! nodeidsに値を入れるための処理
    subroutine SetNodeId(fd, nodeids)
        implicit none
        integer, intent(in) :: fd
        integer, dimension(:,:), intent(out) :: nodeids
        
        character(256) line, tmp
        integer id, a, b, c, d
        
        do
            READ (fd, "(A)", end=300) line
            if (INDEX(line, "*") > 0) then
                goto 300
            end if
            READ (line, *) id, a, b, c, d, tmp
            
            nodeids(:,id) = (/ a, b, c, d /)
        end do
300     continue
        
    end subroutine
    
    ! ノードIDだけ読み込む
    type(NodeData) function nodeid_only_NodeData(fd, path) result(node)
        implicit none
        integer, intent(in) :: fd
        character(*), intent(in) :: path
        
        character(256) line
        integer element_pos, element_count
        
        OPEN (fd, file=path, status="old")
        
        ! 要素の頭を探し，要素数を数えて領域を確保する
        CALL SearchElement(fd)
        element_count = CountElement(fd)
        ALLOCATE (node%nodeids(4,element_count))
        
        ! 頭に戻ってデータをセットする
        REWIND(fd)
        CALL SearchElement(fd)
        CALL SetNodeId(fd, node%nodeids)
        
        CLOSE (fd)
    end function
    
    end module