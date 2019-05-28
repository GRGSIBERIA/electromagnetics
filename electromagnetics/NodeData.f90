    module NodeDataModule
    
    type :: NodeData
    	integer, dimension(:,:), allocatable :: nodeids             ! �v�f�ߓ_�ԍ�
        double precision, dimension(:,:), allocatable :: vertices   ! �ߓ_���W
    end type NodeData
    
    contains
    
    ! *Element�v�f��T��
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
    
    ! �v�f�ߓ_���𐔂���
    ! ��s��������̂Ŏd�l�Ƃ��ċ�s�����Ă͂Ȃ�Ȃ�
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
    
    ! nodeids�ɒl�����邽�߂̏���
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
    
    ! �m�[�hID�����ǂݍ���
    type(NodeData) function nodeid_only_NodeData(fd, path) result(node)
        implicit none
        integer, intent(in) :: fd
        character(*), intent(in) :: path
        
        character(256) line
        integer element_pos, element_count
        
        OPEN (fd, file=path, status="old")
        
        ! �v�f�̓���T���C�v�f���𐔂��ė̈���m�ۂ���
        CALL SearchElement(fd)
        element_count = CountElement(fd)
        ALLOCATE (node%nodeids(4,element_count))
        
        ! ���ɖ߂��ăf�[�^���Z�b�g����
        REWIND(fd)
        CALL SearchElement(fd)
        CALL SetNodeId(fd, node%nodeids)
        
        CLOSE (fd)
    end function
    
    end module