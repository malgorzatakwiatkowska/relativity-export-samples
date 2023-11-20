. "$global:rootDir\Helpers\EndpointsClass.ps1"
. "$global:rootDir\Helpers\WriteInformationClass.ps1"
. "$global:rootDir\Helpers\BaseExportService.ps1"

# Your workspace ID: this is where we point to the workspace where we want to export from
[int]$workspaceId = 1022188

# Export settings parameters
# Your saved search ID
[int]$savedSearchId = 1040263

# ArtifactIds: Example: 1003668 - Extracted Text, 1003677 - Folder Name, 1003676 - Artifact ID, 1003667 - Control Number
$fulltextPrecedenceFieldsArtifactIds = '[1003668,1003677]'
$fieldArtifactIds = '[1003676,1003667]'

# Job related data
$jobId = New-Guid
[string]$applicationName = "Export-Service-Sample-Powershell"
[string]$applicationId = "Sample-Job-" + $MyInvocation.MyCommand.Name.Replace(".ps1", "")

# Export job settings
[string]$exportJobSettings = 
'{
    "settings": {
        "ExportSourceSettings": {
            "ArtifactTypeID":10,
            "ExportSourceType":1,
            "ExportSourceArtifactID":' + $savedSearchId + ',
            "ViewID":1,
            "StartAtDocumentNumber":1
        },
        "ExportArtifactSettings": {
            "FileNamePattern":"{identifier}CustomPatternText{originalfilename}",
            "ExportNative":true,
            "ExportPdf":true,
            "ExportImages":true,
            "ExportFullText":true,
            "ExportMultiChoicesAsNested":true,
            "ImageExportSettings": {
                "ImagePrecedenceArtifactIDs":[-1],
                "TypeOfImage":2,
            },
            "FullTextExportSettings": {
                "ExportFullTextAsFile":true,
                "TextFileEncoding":"utf-8",
                "PrecedenceFieldsArtifactIDs":' + $fulltextPrecedenceFieldsArtifactIds + '
            },
            "NativeFilesExportSettings": {
                "NativePrecedenceArtifactIDs":[-1]
            },
            "FieldArtifactIDs":' + $fieldArtifactIds + ',
            "ApplyFileNamePatternToImages":false
        },
        "ExportOutputSettings": {
            "LoadFileSettings": {
                "LoadFileFormat":"CSV",
                "ImageLoadFileFormat":"IPRO",
                "PdfLoadFileFormat":"IPRO",
                "Encoding":"utf-8",
                "DelimitersSettings": {
                    "NestedValueDelimiter":"B",
                    "RecordDelimiter":"E",
                    "QuoteDelimiter":"D",
                    "NewlineDelimiter":"C",
                    "MultiRecordDelimiter":"A"
                },
                "ExportMsAccess": false
            },
            "VolumeSettings": {
                "VolumePrefix":"VOL_SEARCH_",
                "VolumeStartNumber":"1",
                "VolumeMaxSizeInMegabytes":100,
                "VolumeDigitPadding":5
            },
            "SubdirectorySettings": {
                "SubdirectoryStartNumber":1,
                "MaxNumberOfFilesInDirectory":10,
                "ImageSubdirectoryPrefix":"IMAGE_",
                "NativeSubdirectoryPrefix":"NATIVE_",
                "FullTextSubdirectoryPrefix":"FULLTEXT_",
                "PdfSubdirectoryPrefix":"PDF_",
                "SubdirectoryDigitPadding":5
            },
            "CreateArchive":false,
            "FolderStructure":0
        }
    },
    "applicationName":"' + $applicationName + '",
    "correlationID":"' + $applicationId + '"
}'

# Create, run export job and display export job result
$global:Endpoints = [Endpoints]::new($workspaceId)
$global:WriteInformation = [WriteInformation]::new()
$global:BaseExportService = [BaseExportService]::new()

Context "Exports native, fulltext, images and PDF files from saved search" {
    Describe "Create export job" {
        $global:BaseExportService.createExportJob($jobId, $exportJobSettings)
    }

    Describe "Start export job" {
        $global:BaseExportService.startExportJob($jobId)
    }

    Describe "Wait for export job to be completed" {
        $global:BaseExportService.waitForExportJobToBeCompleted($jobId)
    }

    Describe "Export job summary" {
        $global:BaseExportService.exportJobResult($jobId)
    }
}
