    module ExtractDisplacementModule
    
	contains
    
	! ヘッダの数を数える関数
	integer function HeaderCountX(file) result(count)
		use FileDataModule
		implicit none
		type(FileData), intent(in) :: file
		integer i
		count = 0
		
		do i = 1, file%numof_lines
			if (INDEX(file%lines(i), "  X  ") > 0) then
				count = count + 1
			end if
		end do
    end function
    
    ! ヘッダから情報を抽出する
    subroutine ExtractInformationFromHeader(header, axisid, nodeid)
        character(256), intent(in) :: header
        integer, intent(out) :: axisid, nodeid
        
        character(16) axis
        integer temp
        READ (header(4:4), *) axisid
        
        temp = INDEX(header, ":", back=.TRUE.) + 1
        READ (header(temp+1:), *) nodeid
        
    end subroutine
	
    ! ヘッダを生成する関数
	function GenerateHeader(file, header_count, header_position) result(headers)
		use FileDataModule
		implicit none
		type(FileData), intent(in) :: file
		integer, intent(in) :: header_count
        integer, dimension(header_count), intent(out) :: header_position
		
		character(256), dimension(header_count) :: headers
        character(256) header
		integer i, pos, tmp, count
		
		count = 1
		do i = 1, file%numof_lines
			pos = INDEX(file%lines(i), "  X  ")
			if (pos > 0) then
                header_position(count) = i + 2
                
                ! 後ろに戻りながら空白行が見つかるまでヘッダを作り続ける
                header = file%lines(i)
                header = adjustl(header(pos+5:))
				tmp = i - 1
				do
					if (len_trim(adjustl(file%lines(tmp))) <= 0) then
						goto 100
					end if
					
					header = trim(adjustl(file%lines(tmp))) // header
                    tmp = tmp - 1
				end do
100             continue
                headers(count) = header
                count = count + 1
			end if
		end do
    end function
    
    subroutine ExtractNodeAxisFromHeader(inputfd, inputpath, count, nodeids, axisids, header_positions)
        use FileDataModule
        implicit none
        integer, intent(in) :: inputfd
        character(256), intent(in) :: inputpath
        integer, intent(out) :: count
        integer, dimension(:), allocatable, intent(out) :: nodeids, axisids, header_positions
        
        character(256), dimension(:), allocatable :: headers
        
        integer i
        type(FileData) file
        file = init_FileData(inputfd, inputpath)
        
        ! ヘッダの数をカウントして確保する領域を確定する
		count = HeaderCountX(file)
        ALLOCATE (header_positions(count))
        ALLOCATE (nodeids(count))
        ALLOCATE (axisids(count))
        
		headers = GenerateHeader(file, count, header_positions)
		
        ! ヘッダの情報を抜き出す
        !$omp parallel
        !$omp do
        do i = 1, size(headers)
            CALL ExtractInformationFromHeader(headers(i), axisids(i), nodeids(i))
        end do
        !$omp end do
        !$omp end parallel
    end subroutine
	
    ! レポートから変位を抽出する
    subroutine ExtractDisplacementFromReport(nodepath, input, output)
		use FileDataModule
		use FileUtil
        use NodeDataModule
        implicit none
        character(256), intent(in) :: input, output, nodepath
		
		integer inputfd, nodefd, header_count, maximum_id
        integer, dimension(:), allocatable :: nodeids, axisids, header_positions
		type(FileData) file
        type(NodeData) node
        
        CALL Exists(nodepath)
		CALL Exists(input)
        
        inputfd = ScanValidFD(20)
        nodefd = ScanValidFD(inputfd + 1)
        
        ! ヘッダの情報を抜き出す
		CALL ExtractNodeAxisFromHeader(inputfd, input, header_count, nodeids, axisids, header_positions)
        
        ! 使用する節点情報を読み込む
        node = nodeid_only_NodeData(nodefd, nodepath)
        maximum_id = MAXVAL(node%nodeids)
        PRINT *, "MAXIMUM NODE ID:", maximum_id
        
        ! 最後に領域を解放する
        DEALLOCATE (nodeids)
        DEALLOCATE (axisids)
        DEALLOCATE (header_positions)
	
    end subroutine
    
    end module