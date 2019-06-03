    module PartFileModule
    implicit none
    
    type PartData
        integer :: maximum_node_id
        double precision, dimension(:,:), allocatable :: nodes
        integer, dimension(:,:), allocatable :: elements
        double precision, dimension(3) :: translate, rotate
    end type
    
    contains
    
    ! "*"のついた要素を探す
    ! status == 0 は正常
    ! status != 0 は異常
    ! requirement == 1 は必須
    ! requirement == 0 は任意
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
        
        ! タグが存在しない場合の処理
200     continue
        if (requirement == 1) then
            PRINT *, "DO NOT FOUND A TAG: ", tag
            STOP
        end if
        status = 1  ! require == 0 の場合はstatusのみセットする
        goto 210
        
100     continue
        status = 0
        
210     continue        
    end function
    
    ! *Element要素を探索
    function ReadElements(fd) result(elements)
        implicit none
        integer, intent(in) :: fd
        character(256) line
        integer count, i, id, a, b, c, d, status
        integer, dimension(:,:), allocatable :: elements
        
        ! Element要素を見つける
        REWIND (fd)
        status = FindTag(fd, "*Element", 1)
        
        ! 次の要素が来る，もしくは行が終わりになるまでカウントする
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
        
        ! idが最初に来るのでそこに入れる
        do i = 1, count
            READ (fd, *) id, a, b, c, d
            elements(:,id) = (/ a, b, c, d /)
        end do
        
    end function
    
    ! 節点座標の読み込み処理
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
            
            ! 最大要素番号以下なら読み込む
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
        
        ! status == 0で存在しているので，存在していれば読み込む
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
        
        ! 最初に要素節点の最大節点番号を洗い出す
        part%elements = ReadElements(fd)
        part%maximum_node_id = MAXVAL(part%elements)
        
        ! 最大節点番号以下の節点座標を読み込む
        part%nodes = ReadNodes(fd, part%maximum_node_id)
        
        ! translateとrotateの読み込み
        part%translate = ReadTransform(fd, "*Translate")
        part%rotate = ReadTransform(fd, "*Rotate")
        
    end function
    
    end module