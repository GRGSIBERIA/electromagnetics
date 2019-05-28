    module ExtractDisplacementModule
    implicit none
    
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
    
    type(FileData) function ExtractNodeAxisFromHeader(inputfd, inputpath, count, nodeids, axisids, header_positions) result(file)
        use FileDataModule
        implicit none
        integer, intent(in) :: inputfd
        character(256), intent(in) :: inputpath
        integer, intent(out) :: count
        integer, dimension(:), allocatable, intent(out) :: nodeids, axisids, header_positions
        
        character(256), dimension(:), allocatable :: headers
        
        integer i
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
    end function
    
    integer function CountTime(lines, top_header_pos) result(count)
        use FileDataModule
        implicit none
        character(*), dimension(:), allocatable, intent(in) :: lines
        integer, intent(in) :: top_header_pos
        integer i
        
        count = 0
        i = top_header_pos
        do
            if (len_trim(lines(i)) < 1) then
                goto 200
            end if
            count = count + 1
            i = i + 1
        end do
200     continue
    end function
    
    double precision function ReadDisplacementFromLine(line) result(val)
        implicit none
        character(160), intent(in) :: line
        double precision tmp
        
        READ (line, *) tmp, val
    end function
    
    subroutine ReadDisplacementFromReport(file, header_count, header_positions, nodeids, axisids, numof_times, maximum_id, histories)
        use FileDataModule
        implicit none
        type(FileData), intent(in) :: file
        integer, intent(in) :: header_count
        integer, dimension(header_count) :: header_positions, nodeids, axisids
        integer, intent(in) :: numof_times, maximum_id
        double precision, dimension(3, numof_times, maximum_id) :: histories
        
        integer hcnt    ! ヘッダーカウント
        integer lcnt    ! 行カウント
        double precision tmp
        
        !$omp parallel
        !$omp do
        do hcnt = 1, header_count
            do lcnt = 1, numof_times
                if (nodeids(hcnt) <= maximum_id) then
                    histories(axisids(hcnt), lcnt, nodeids(hcnt)) = ReadDisplacementFromLine(file%lines(header_positions(hcnt) + lcnt - 1))
                end if
            end do
        end do
        !$omp end do
        !$omp end parallel
    end subroutine
    
    subroutine WriteDisplacementFromData(output, maximum_id, numof_times, histories)
        use FileUtil
        implicit none
        character(256), intent(in) :: output
        integer, intent(in) :: maximum_id, numof_times
        double precision, dimension(3, numof_times, maximum_id), intent(in) :: histories
        
        integer outputfd, nid, tid
        
        outputfd = ScanValidFD(30)
        OPEN (outputfd, file=output, status="replace")
        
        WRITE (outputfd, *) "*Time", numof_times
        WRITE (outputfd, *) "*Vertex", maximum_id
        
        do nid = 1, maximum_id
            if (SUM(histories(:, :, nid)) == 0.0d0) then
                goto 300
            end if
            
            WRITE (outputfd, *) "*Node", nid
            
            do tid = 1, numof_times
                WRITE (outputfd, *) histories(:, tid, nid)
            end do
            
300         continue            
        end do
        
        CLOSE (outputfd)
        
    end subroutine
	
    ! レポートから変位を抽出する
    subroutine ExtractDisplacementFromReport(nodepath, input, output)
		use FileDataModule
		use FileUtil
        use NodeDataModule
        implicit none
        character(256), intent(in) :: input, output, nodepath
		
		integer inputfd, nodefd, header_count, maximum_id, numof_times
        integer, dimension(:), allocatable :: nodeids, axisids, header_positions
        double precision, dimension(:,:,:), allocatable :: histories
        
		type(FileData) file
        type(NodeData) node
        
        CALL Exists(nodepath)
		CALL Exists(input)
        
        inputfd = ScanValidFD(20)
        nodefd = ScanValidFD(inputfd + 1)
        
        ! ヘッダの情報を抜き出す
		file = ExtractNodeAxisFromHeader(inputfd, input, header_count, nodeids, axisids, header_positions)
        
        ! 使用する節点情報を読み込む
        node = nodeid_only_NodeData(nodefd, nodepath)
        maximum_id = MAXVAL(node%nodeids)   ! 最大の節点番号
        PRINT *, "MAXIMUM NODE ID:", maximum_id
        
        ! 時間の数をカウントする
        numof_times = CountTime(file%lines, header_positions(1))
        PRINT *, "NUMBER OF TIMES:", numof_times
        
        ! 時刻歴の領域を確保する
        ALLOCATE (histories(3, numof_times, maximum_id))
        histories = 0.0d0
        
        ! 時刻歴を読み込む
        CALL ReadDisplacementFromReport(file, header_count, header_positions, nodeids, axisids, numof_times, maximum_id, histories)
        
        ! 時刻歴を書き出す
        CALL WriteDisplacementFromData(output, maximum_id, numof_times, histories)
        
        ! 最後に領域を解放する
        DEALLOCATE (nodeids)
        DEALLOCATE (axisids)
        DEALLOCATE (header_positions)
	    DEALLOCATE (histories)
        
    end subroutine
    
    end module