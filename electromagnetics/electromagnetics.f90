
    program ElectroMagnetics
    use FileDataModule
    implicit none

    type(FileData) file
    file = init_FileData(20, "E:\temp\abaqus.rpt")
    
    end program ElectroMagnetics

