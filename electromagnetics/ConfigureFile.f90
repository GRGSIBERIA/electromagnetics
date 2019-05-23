    module ConfigureFileModule
    implicit none
    
    ! 入力ファイル用の構造体
    type InputFile
        ! inputはジオメトリの情報
        ! reportは入力する時刻歴データの情報
        integer :: inputfd, reportfd
    end type
    
    ! 設定ファイルの構造体
    type ConfigureFile
        integer :: output_fd
        
        integer :: numof_parts, numof_coils
        integer, dimension(:), allocatable :: part_input_fds, part_report_fds
        integer, dimension(:), allocatable :: top_report_fds, bottom_report_fds
        integer, dimension(:), allocatable :: top_input_fds, bottom_input_fds
        
        type(InputFile), dimension(:), allocatable :: parts, tops, bottoms
    end type
    
    contains
    
    ! InputFile構造体の初期化
    type(InputFile) function init_InputFile(nowfd, inputpath, reportpath) result(file)
        implicit none
        integer, intent(inout) :: nowfd
        character(256), intent(in) :: inputpath, reportpath
        
        CALL ReadAsOpen(inputpath, nowfd, file%inputfd, "old")
        CALL ReadAsOpen(reportpath, nowfd, file%reportfd, "old")
    end function
    
    ! ファイルを読み込んでから，ファイルを開く処理を行う
    subroutine ReadAsOpen(line, nowfd, fd, status)
        use FileUtil
        implicit none
        character(*), intent(in) :: line
        integer, intent(inout) :: nowfd
        integer, intent(out) :: fd
        character(*), intent(in) :: status
        
        character(256) path
        
        READ (line, "(A)") path
        
        ! oldの場合，ファイルが存在するかチェックする
        if (INDEX(status, "old") > 0) then
            CALL Exists(path)
        end if
        
        fd = nowfd
        OPEN (nowfd, file=path, status=status, blocksize=1024, buffercount=1024)
        nowfd = nowfd + 1
        
    end subroutine
    
    type(ConfigureFile) function init_ConfigureFile(fd, path, startfd) result(config)
        use FileDataModule
        implicit none
        
        integer, intent(in) :: fd, startfd
        character(*), intent(in) :: path
        
        type(FileData) file
        character(256) :: inputpath, reportpath
        integer i, count, nowfd, part_count, coil_count
        
        nowfd = startfd
        file = init_FileData(fd, path)
        config%numof_parts = 0
        config%numof_coils = 0
        part_count = 0
        coil_count = 0
        
        ! ファイルの数などを数える
        do i = 1, file%numof_lines
            if (INDEX(file%lines(i), "*InputFile") > 0) then
                config%numof_parts = config%numof_parts + 1
            else if (INDEX(file%lines(i), "*CoilFile") > 0) then
                config%numof_coils = config%numof_coils + 1
            end if
        end do
        
        ALLOCATE(config%parts(config%numof_parts))
        ALLOCATE(config%tops(config%numof_coils))
        ALLOCATE(config%bottoms(config%numof_coils))
        
        ! 実際に設定を読み込む
        count = 1
        do
            if (INDEX(file%lines(count), "*OutputFile") > 0) then
                ! *OutputFile (1つだけ定義，複数存在する場合は後続の定義に置換)
                ! 出力ファイルへのパス
                count = count + 1
                CALL ReadAsOpen(file%lines(count), nowfd, config%output_fd, "replace")
                
            else if (INDEX(file%lines(count), "*InputFile") > 0) then
                ! *InputFile (複数定義可能)
                ! 節点座標のパス
                ! レポートのパス
                count = count + 1
                part_count = part_count + 1
                
                ! 磁化するパートの読み込み
                config%parts(part_count) = init_InputFile(nowfd, file%lines(count), file%lines(count + 1))
                count = count + 1
                
            else if (INDEX(file%lines(count), "*CoilFile") > 0) then
                ! *CoilFile (複数定義可能)
                ! topの節点座標のパス
                ! topのレポートのパス
                ! bottomの節点座標のパス
                ! bottomのレポートのパス
                count = count + 1
                coil_count = coil_count + 1
                
                ! コイル上面の読み込み
                config%tops(coil_count) = init_InputFile(nowfd, file%lines(count), file%lines(count + 1))
                
                ! コイル底面の読み込み
                config%bottoms(coil_count) = init_InputFile(nowfd, file%lines(count + 2), file%lines(count + 3))
                
                count = count + 3
            end if
            
            count = count + 1
        end do
        
        
        
    end function
    
    end module