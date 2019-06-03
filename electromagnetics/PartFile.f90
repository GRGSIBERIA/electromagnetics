    module PartFileModule
    implicit none
    
    type PartData
        integer :: maximum_node_id
        double precision, dimension(:,:), allocatable :: nodes
        integer, dimension(:,:), allocatable :: elements
        double precision, dimension(3) :: translate, rotate
    end type
    
    contains
    
    ! "*"�̂����v�f��T��
    ! status == 0 �͐���
    ! status != 0 �ُ͈�
    ! requirement == 1 �͕K�{
    ! requirement == 0 �͔C��
    integer function FindTag(fd, tag, requirement) result(status)
        implicit none
        integer, intent(in) :: fd, requirement
        character*(*), intent(in) :: tag
        character(256) line
        
        do
            READ (fd, "(A)", end=200) line
            if (INDEX(line, tag) > 0) then
                goto 100
            end if
        end do
        
        ! �^�O�����݂��Ȃ��ꍇ�̏���
200     continue
        if (requirement == 1) then
            PRINT *, "DO NOT FOUND A TAG: ", tag
            STOP
        end if
        status = 1  ! require == 0 �̏ꍇ��status�̂݃Z�b�g����
        goto 210
        
100     continue
        status = 0
        
210     continue        
    end function
    
    ! *Element�v�f��T��
    function ReadElements(fd) result(elements)
        implicit none
        integer, intent(in) :: fd
        character(256) line
        integer count, i, id, a, b, c, d, status
        integer, dimension(:,:), allocatable :: elements
        
        ! Element�v�f��������
        REWIND (fd)
        status = FindTag(fd, "*Element", 1)
        
        ! ���̗v�f������C�������͍s���I���ɂȂ�܂ŃJ�E���g����
        count = 0
        do
            READ (fd, "(A)", end=200) line
            if (INDEX(line, "*") > 0 .or. len_trim(line) < 4) then
                goto 200
            end if
            count = count + 1
        end do
200     continue
        ALLOCATE (elements(4,count))
        
        REWIND (fd)
        status = FindTag(fd, "*Element", 1)
        
        ! id���ŏ��ɗ���̂ł����ɓ����
        do i = 1, count
            READ (fd, *) id, a, b, c, d
            elements(:,id) = (/ a, b, c, d /)
        end do
        
    end function
    
    ! �ߓ_���W�̓ǂݍ��ݏ���
    function ReadNodes(fd, maximumid) result(nodes)
        implicit none
        integer, intent(in) :: fd, maximumid
        double precision, dimension(:,:), allocatable :: nodes
        character(256) line
        integer id, status
        double precision a, b, c
        
        ALLOCATE (nodes(3, maximumid))
        REWIND (fd)
        
        status = FindTag(fd, "*Node", 1)
        
        do
            READ (fd, "(A)", end=400) line
            if (INDEX(line, "*") > 0) then
                goto 400
            end if
            if (len_trim(line) < 4) then
                goto 500
            end if
            
            READ (line, *) id, a, b, c
            
            ! �ő�v�f�ԍ��ȉ��Ȃ�ǂݍ���
            if (id <= maximumid) then
                nodes(:,id) = (/ a, b, c /)
            end if
        end do
        
500     continue
        PRINT *, "DO NOT INCLUDED A BLANK LINE"
        STOP
        
400     continue        
    
    end function
    
    function ReadTransform(fd, tag) result(value)
        implicit none
        integer, intent(in) :: fd
        character*(*), intent(in) :: tag
        double precision, dimension(3) :: value
        integer status
        
        value = 0.0d0
        
        REWIND (fd)
        status = FindTag(fd, tag, 0)
        
        ! status == 0�ő��݂��Ă���̂ŁC���݂��Ă���Γǂݍ���
        if (status == 0) then
            READ (fd, *) value(1), value(2), value(3)
        end if
    end function
    
    type(PartData) function init_PartData(path) result(part)
        USE FileUtil
        implicit none
        character*(*), intent(in) :: path
        
        integer fd
        
        CALL Exists(path)
        fd = ScanValidFD(fd)
        
        ! �ŏ��ɗv�f�ߓ_�̍ő�ߓ_�ԍ���􂢏o��
        part%elements = ReadElements(fd)
        part%maximum_node_id = MAXVAL(part%elements)
        
        ! �ő�ߓ_�ԍ��ȉ��̐ߓ_���W��ǂݍ���
        part%nodes = ReadNodes(fd, part%maximum_node_id)
        
        ! translate��rotate�̓ǂݍ���
        part%translate = ReadTransform(fd, "*Translate")
        part%rotate = ReadTransform(fd, "*Rotate")
        
    end function
    
    end module