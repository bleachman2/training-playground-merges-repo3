pipeline {
	agent {
		dockerfile {dir "training-playground-merges-repo3"}
		//filename 'Dockerfile' not needed since name is already the default one

		}

  	
  	options { 
  		//TODO add option to avoid concurrent builds
		disableConcurrentBuilds()
	}


	environment {
		CONFIGS = '''{\
		repositoryConfigs:[\
			{\
				name:"training-playground-merges-repo1",\
				urlWithoutProtocol:"github.com/bleachman2/training-playground-merges-repo1",\
				credentialId:"nb24871_git"\
			},\
			{\
				name:"training-playground-merges-repo2",\
				urlWithoutProtocol:"github.com/bleachman2/training-playground-merges-repo2",\
				credentialId:"nb24871_git"\
			}\
		],\
		mergeConfigs:[\
			{\
			sourceRepository:"training-playground-merges-repo1",\
				targetRepository:"training-playground-merges-repo2",\
				oneToOneMapping:"main:main",\
				oneToManyMapping:"",\
				manyToManyMapping:""\
			}\
		]\
		}''' //TODO create json tree object
		
		SEND_SUCCESS_EMAIL_TO = 'nb24871@novabase.pt'	
		SEND_SUCCESS_EMAIL_SUBJECT = 'Automatic merge results report'
		SEND_SUCCESS_EMAIL_TEMPLATE_PATH = 'email-templates/success.html' 

		SEND_MAINTENANCE_EMAIL_TO = 'nb24871@novabase.pt'	
		SEND_MAINTENANCE_EMAIL_SUBJECT = 'Automatic merge results maintenance'
		SEND_MAINTENANCE_EMAIL_TEMPLATE_PATH = 'email-templates/maintenace.html' 
  	}

  	stages {
    	stage('Setup Remotes') {
      		steps { 
      			script {
				sh 'if git show-ref --quiet refs/heads/init; then git branch -D init; fi'
				sh 'git checkout -b init'
				
				def json_tree_conf =readJSON tree: env.CONFIGS
				json_tree_conf.repositoryConfigs.each{json_tree ->

				withCredentials([usernamePassword(credentialsId: json_tree.credentialId, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
				
				setupRemote(json_tree.name, json_tree.urlWithoutProtocol, env.USERNAME, env.PASSWORD)
				}
				
				}
      				
					// TODO use readJSON to read CONFIGS to a local variable
					// for each repositoryConfig object call setupRemote method with defined parameters already implemented
					// use withCredentials to get password and user from jenkins
					    }
      		}
    	}
    	stage('Perform Merges') {
      		steps { 
      			script {
				
					def json_configs =readJSON(tree: env.CONFIGS)
					def mergeReport = []
					
					json_configs.mergeConfigs.each {json_var ->
						def oneToOne = json_var.oneToOneMapping
						def oneToManyConverted = convertOneToManyIntoOneToOneMapping(targetRepository,oneToManyMapping)
						def manyToManyConverted = convertManyToManyIntoOneToOneMapping(sourceRepository,manyToManyMapping)
						def allBranch = (oneToOne + " " + oneToManyConverted + " " + manyToManyConverted).replaceAll("  "," ").trim()
						def res=performMerges(json_var.sourceRepository,json_var.targetRepository,allBranch)
						if (res != null){mergeReport.addAll(res)}
					
					}
					
					
					


					
      			    // TODO use readJSON to read CONFIGS to a local variable
					// for each mergeConfig object assign oneToOneMapping to a variable and use convertOneToManyIntoOneToOneMapping 
					// and convertManyToManyIntoOneToOneMapping to convert the other JSON options to oneTOone, split the strings by " " like 
					// String1 + " " + String2 + " " + convertManyToManyIntoOneToOneMapping
					// call performMerges method with defined parameters already implemented and assign the return value to a variable like mergesPerformed
					// don´t forget to use replaceAll("  ", " ").trim() to avoid two spaces instead of one
					// Then check if mergesPerformed is not null and add it to mergeReport
					
					
					sh "git checkout init"
					//TODO convert mergeReport using groovy.json.JsonOutput.toJson and write mergeReport to an json file
					def margeReportJson = groovy.json.JsonOutput.toJson(mergeReport)
					writeJson(file: 'margeReport.json', json: mergeReportJson)
      			}
      		}
    	}
  	}
	post { 
        success { 
  			script {
			//TODO read mergeReport json file
			// call success email with report data
  			}
			// clean server
        	sh "git clean -d -fx . && git checkout -f init && git config --unset credential.helper"
        }
        unstable {
        	sh "git clean -d -fx . && git checkout -f init && git config --unset credential.helper"
			//TODO call maintenance email
           
        }
		failure {
			sh "git clean -d -fx . && git checkout -f init && git config --unset credential.helper"
		    //TODO call maintenance email
		}
    }
}

/*****************************************
* Send a Success email
****************************************/
def sendSuccessEmail(mergeReportData = '') {
	echo mergeReportData.toString()
	
	//TODO read html template file for success email with ENV variable already defined SEND_SUCCESS_EMAIL_TEMPLATE_PATH
	
	
	//TODO define and use 3 variables errorRowTemplateSpecs, successRowTemplateSpecs, noneRowTemplateSpecs to get the placeholders ROWS
	// use findEmailRowTemplate method with parameters
	
	boolean logErrors = errorRowTemplateSpecs != null
	boolean logSuccess = successRowTemplateSpecs != null
	boolean logNone = noneRowTemplateSpecs != null

	if (!logErrors && !logSuccess && !logNone) {
		emailext 	subject: "$SEND_SUCCESS_EMAIL_SUBJECT", 
    				to: "$SEND_SUCCESS_EMAIL_TO",
    				body: emailTemplate
    	return;
	}

	def errorRowsHTML = ""<<""
	def successRowsHTML = ""<<""
	def noneRowsHTML = ""<<""
	
	if (mergeReportData != null) {
		//TODO read json configs
		// for each mergeReportData.toArray() if
		// rowData "result" = ERROR update errorRowsHTML with the result of fillDataInHTMLRow method wit correct parameters
		// rowData "result" = SUCCESS update successRowsHTML with the result of fillDataInHTMLRow method wit correct parameters
		// rowData "result" = NONE update noneRowsHTML with the result of fillDataInHTMLRow method wit correct parameters
		
	}
	
	//TODO create and fill in a variable emailBody with returned values of fillEmailRows method for errorRowsHTML, successRowsHTML and noneRowsHTML
	
	emailext subject: "$SEND_SUCCESS_EMAIL_SUBJECT", 
			 to: "$SEND_SUCCESS_EMAIL_TO",
			 body: emailBody
}

/*****************************************
* Injects data in a HTML row template  
****************************************/
def fillDataInHTMLRow(rowTemplate = '', rowData = '', repositoryConfigs = [ ]) {
	def sourceRepository = rowData.getString("sourceRepository")
	def sourceBranch = rowData.getString("sourceBranch")
	
	def targetRepository = rowData.getString("targetRepository")
	def targetBranch = rowData.getString("targetBranch")

	def lastIndexOfSlashInSourceBranch = sourceBranch.lastIndexOf("/")
	lastIndexOfSlashInSourceBranch = lastIndexOfSlashInSourceBranch != -1 ? lastIndexOfSlashInSourceBranch + 1 : 0 
	
	def lastIndexOfSlashInTargetBranch = targetBranch.lastIndexOf("/")
	lastIndexOfSlashInTargetBranch = lastIndexOfSlashInTargetBranch != -1 ? lastIndexOfSlashInTargetBranch + 1 : 0 
	
	return   rowTemplate.replaceAll("PLACEHOLDER_ROW_SOURCE_REPO_NAME", sourceRepository)
						.replaceAll("PLACEHOLDER_ROW_SOURCE_BRANCH_PATH", sourceBranch)
						.replaceAll("PLACEHOLDER_ROW_SOURCE_BRANCH_NAME", sourceBranch.substring(lastIndexOfSlashInSourceBranch))
						.replaceAll("PLACEHOLDER_ROW_SOURCE_BRANCH_URL", makeBranchURL(sourceRepository, sourceBranch, repositoryConfigs))
						.replaceAll("PLACEHOLDER_ROW_TARGET_REPO_NAME", targetRepository)
						.replaceAll("PLACEHOLDER_ROW_TARGET_BRANCH_PATH", targetBranch)
						.replaceAll("PLACEHOLDER_ROW_TARGET_BRANCH_NAME", targetBranch.substring(lastIndexOfSlashInTargetBranch))
						.replaceAll("PLACEHOLDER_ROW_TARGET_BRANCH_URL", makeBranchURL(targetRepository, targetBranch, repositoryConfigs))
						.replaceAll("PLACEHOLDER_ROW_TARGET_BRANCH_LAST_COMMITTER", rowData.getString("lastCommitterBeforeMerge"))
}

def makeBranchURL(repositoryName = '', branchPath = '', repositoryConfigs = [ ]) {
	def repositoryConfig = repositoryConfigs.find { it.name == repositoryName }
	return "https://" + repositoryConfig.urlWithoutProtocol + "/tree/" + branchPath
}

/*****************************************
* Replaces in the email body the rows template
* placeholder with the rows HTML provided as input  
****************************************/
def fillEmailRows(performFill = false, emailBody = '', rowTemplateSpecs = '', rowsHTML = '') {
	if (performFill != true) {
		return emailBody
	}
	return emailBody.replaceAll(rowTemplateSpecs.rowsPlaceholder, rowsHTML)
}

/*****************************************
* Searched in the email template for a 
* specific row template delimmited by the 
* placeholder provided as input
****************************************/
def findEmailRowTemplate(emailTemplate = '', placeholder = '') {
	if (emailTemplate == null || placeholder == null) {
		return null
	}
	
	def indexOfPlaceholderStart = emailTemplate.indexOf(placeholder + "_START")
	def indexOfPlaceholderEnd = emailTemplate.indexOf(placeholder + "_END")
	
	if (indexOfPlaceholderStart == -1 || indexOfPlaceholderEnd == -1) {
		return null
	}
	
	def placeholderStartLength = (placeholder + "_START").length()
	def placeholderEndLength = (placeholder + "_END").length()
	return [
		rowsPlaceholder : emailTemplate.substring(indexOfPlaceholderStart, indexOfPlaceholderEnd + placeholderEndLength),
		rowTemplate : emailTemplate.substring(indexOfPlaceholderStart + placeholderStartLength, indexOfPlaceholderEnd)
	]
}

/*****************************************
* Send a MAINTENANCE email
****************************************/
def sendMaintenanceEmail() {
    emailext 	subject: "$SEND_MAINTENANCE_EMAIL_SUBJECT", 
    			to: "$SEND_MAINTENANCE_EMAIL_TO",
    			body: readFile("$SEND_MAINTENANCE_EMAIL_TEMPLATE_PATH")
}



/*****************************************
* Add repo remote to workspace and 
* perform git fetch
****************************************/
def setupRemote(name = '', urlWithoutProtocol = '', username = '', password = '') {
	boolean remoteExists = (sh(returnStdout: true, script: 'if [[ $(git remote | grep ^' + name + '$) ]]; then echo "true"; else echo "false"; fi').trim() == "true")
	
	if (remoteExists) {
		//Set remote url (to be sure)
		sh "git remote set-url " + name + " https://" + urlWithoutProtocol
	}
	else {
		//Create remote
		sh "git remote add " + name + " https://" + urlWithoutProtocol
	}

	sh "echo 'https://" + java.net.URLEncoder.encode(username, "UTF-8") + ":" + java.net.URLEncoder.encode(password, "UTF-8") + "@"+ urlWithoutProtocol + "' >> '$WORKSPACE/.git/.git-credentials'"
	sh "git config credential.helper \"store --file='$WORKSPACE/.git/.git-credentials'\""

	// remove all local tags & fetch remote tags
	sh "git tag -l | xargs git tag -d && git fetch -t"
	//Fetch remote
	sh "git fetch -f -P -p " + name
}

/*****************************************
* Convert the pattern mapping to 
* a direct branch map config
****************************************/
def convertOneToManyIntoOneToOneMapping(targetRepository = '', oneToManyMapping = '') {
	if (oneToManyMapping == null || oneToManyMapping.trim() == "") {
		return ""
	}
	
	def oneToOneMapping = ""<<""
	def oneToManyMappingList = oneToManyMapping.trim().split(' ')

    oneToManyMappingList.each { oneToManyMappingItem ->
		if (oneToManyMappingItem.contains(":")) {
			def oneToManyMappingItemConfig = oneToManyMappingItem.split(':')
			def sourceBranch = oneToManyMappingItemConfig[0]
			def targetPattern = oneToManyMappingItemConfig[1]
			
			def newOneToOneMapping = sh(returnStdout: true, script: "git branch -r | \
																	 grep $targetRepository/$targetPattern | \
																	 sed -e 's@^  $targetRepository/@@g' | \
																	 xargs -I {} echo $sourceBranch:{}")

			newOneToOneMapping = newOneToOneMapping.replaceAll("\n"," ").trim()
			oneToOneMapping <<= newOneToOneMapping
		}
	}
	
	return oneToOneMapping.toString()
}

/*****************************************
* Convert the pattern mapping to 
* a direct branch map config
****************************************/
def convertManyToManyIntoOneToOneMapping(sourceRepository = '', manyToManyMapping = '') {
	if (manyToManyMapping == null || manyToManyMapping.trim() == "") {
		return ""
	}
	
	def oneToOneMapping = ""<<""
	def manyToManyMappingList = manyToManyMapping.trim().split(' ')

    manyToManyMappingList.each { manyToManyMappingItem ->
		if (manyToManyMappingItem.contains(":")) {
			def manyToManyMappingItemConfig = manyToManyMappingItem.split(':')
			def sourcePattern = manyToManyMappingItemConfig[0]
			def targetPattern = manyToManyMappingItemConfig[1]
			
			def newOneToOneMapping = sh(returnStdout: true, script: "git branch -r | \
																	 grep $sourceRepository/$sourcePattern | \
																	 sed -e 's@^  $sourceRepository/@@g' | \
																	 xargs -I {} echo {}:{} | \
																	 sed -e 's@:${sourcePattern}@:${targetPattern}@g'")

			newOneToOneMapping = newOneToOneMapping.replaceAll("\n"," ").trim()
			oneToOneMapping <<= newOneToOneMapping
		}
	}

	return oneToOneMapping.toString()
}

/*****************************************
* Merge the branches based in a direct 
* mapping between source and target
****************************************/
def performMerges(sourceRepository = '', targetRepository = '', oneToOneMapping = '') {
	if (oneToOneMapping == null || oneToOneMapping.trim() == "") {
		return
	}
	
	//TODO trim oneToOneMapping variable by space ' ' and assign it to a variable  
	def trimmedMapping=oneToManyMapping.trim().split(' ')
	def mergeReport = []	
	
	// TODO for each one to one mapping check if cointains ":", if so split it to get the source branch and the target branch
	trimmedMapping.each{row->
		if (row.contains(":")) {
			def splitedMapping=row.split(":")
			def sourceBranch = splitedMapping[0]
			def targetBranch = splitedMapping[1]
			mergeReport.add(mergeBranches(sourceRepository,sourceBranch,targetRepository,targetBranch))
			}
	}
	// Then call mergeBranches with the requested parameters
	// Analyse mergeBranches
	
        
    return mergeReport
}

/*****************************************
* To use this function to merge the 
* legacy branch into the new branch
* Both provided as input
****************************************/
def mergeBranches(sourceRepository = '', sourceBranch = '', targetRepository = '', targetBranch = '') {
	echo "##### Merging '$sourceBranch' from '$sourceRepository' into '$targetBranch' from '$targetRepository' #####"

	//Switch to init branch to enable reset of "local-legacy" and "local-origin"
	sh "git clean -d -fx . && git checkout -f init"
	
	//Remove "local-legacy" and "local-origin" braches if they exist
	sh "if git show-ref --quiet refs/heads/local-legacy; then git branch -D local-legacy; fi"
	sh "if git show-ref --quiet refs/heads/local-origin; then git branch -D local-origin; fi"
	
	//Checkout $sourceBranch (it should always exist) into "local-legacy"
	sh "git checkout -b local-legacy $sourceRepository/$sourceBranch"
	
	//Hash of commit in source branch
	def headCommitSourceBranch = sh(returnStdout: true, script: "echo \$(git log --pretty=format:'%H' -n 1)").trim()
	
	//Get baseline from source if branch doesn't exist in target
	boolean isNewBranchInTarget = sh(returnStdout: true, script: "git branch -r | egrep '$targetRepository/$targetBranch\$' || echo ''").trim().isEmpty()
	if (isNewBranchInTarget) {
		sh "git checkout -b local-origin $sourceRepository/$sourceBranch"
	}
	else {
		sh "git checkout -b local-origin $targetRepository/$targetBranch"
	}
		
	//Store hash of commit before merge	
	def headCommitBeforeMerge = sh(returnStdout: true, script: "echo \$(git log --pretty=format:'%H' -n 1)").trim()
	def headCommitAuthorBeforeMerge = sh(returnStdout: true, script: "echo \$(git show --format=\"%aN\" \"$headCommitBeforeMerge\" | awk 'NR == 1')").trim()
	
	//Perform merge
	sh "git merge --ff local-legacy --allow-unrelated-histories -m \"Merge branch '$sourceBranch' into '$targetBranch'\" || true"

	//Hash of commit after merge
	def headCommitAfterMerge = sh(returnStdout: true, script: "echo \$(git log --pretty=format:'%H' -n 1)").trim()
	
	//Find common anchestor to identify if there was merge conflicts
	def commonAncestor = sh(returnStdout: true, script: "echo \$(git merge-base local-legacy local-origin)").trim()

	//Prepare report item
	def mergeReportItem = [ 
	    sourceRepository : sourceRepository,
	    sourceBranch : sourceBranch,
	    targetRepository : targetRepository,
	    targetBranch : targetBranch,
	    lastCommitterBeforeMerge : headCommitAuthorBeforeMerge
	]

	if (isNewBranchInTarget || headCommitBeforeMerge != headCommitAfterMerge) {
		sh "git push $targetRepository HEAD:$targetBranch"
		mergeReportItem.result = "SUCCESS"
    }
    else if (commonAncestor != headCommitSourceBranch) {
		sh "git reset --merge"
		mergeReportItem.result = "ERROR"
    }
    else {
	    mergeReportItem.result = "NONE"
    }
	return mergeReportItem
}