<cf_layout page="Files" title="Files">
<cfoutput>
<div x-data="data" data-reflect-root="">
	<div class="card"
		 @dragover.prevent="highlight = true"
		 @dragleave.prevent="highlight = false"
		 @drop.prevent="handleDrop($event)"
		 :class="{'dragover': highlight}">
		<div class=" card-header-files bg-gray-200">
			<ol class="breadcrumb breadcrumb-dark  text-big container-p-x py-3 m-0">
				<template x-for="crumb in pathArray">
					<li class="breadcrumb-item" :class="{ 'active': isCurrent(crumb) }">
						<a @click="directoryGo( crumb )" x-text="crumb.name" ></a>
					</li>
				</template>
			</ol>
		</div>
		<div class="card-body flex-grow-1 light-style container-p-y ">
			<div class="container-m-nx container-m-ny bg-lightest mb-3 ">

				<div class="row justify-content-between">
					<div class="col-auto">
						<div class="file-field ">
						<div class="d-flex ms-xl-3">
							<div class="d-flex">
								<input  class="form-control" type="file" name="file_input" id="file_input" :disabled="uploadComponent.uploading" @change="fileInputChange()">
								<button type="button" class="btn btn-primary mr-2"><i class="ion ion-md-cloud-upload"></i>&nbsp; #request.i18n.getValue("Upload")#</button>
							</div>
						</div>
					</div>
					</div>
					<div class="col " id="progress_wrapper" x-show="uploadComponent.uploading">
						<div id="progress_status" x-text="uploadComponent.progressLabel"></div>
						<div class="progress mb-3">
							<div id="progress" class="progress-bar" role="progressbar" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" :style="`width: ${uploadComponent.progressWidth}%;`"></div>
						</div>
					</div>
					<div class="col align-items-end col-auto">
						<button type="button" class="btn btn-outline-primary mr-2" data-bs-toggle="modal" data-bs-target="##createFolderModal"><i class="bi bi-folder-fill"></i> #request.i18n.getValue("Create folder")#</button>
						<button type="button" class="btn btn-outline-info ms-2" @click="deleteDir( )" x-show="!isRoot"><i class="bi bi-x-circle-fill"></i> #request.i18n.getValue("Delete")#</button>
					</div>
				</div>
			</div>
			<div class="file-manager-container file-manager-col-view">
				<div class="file-item" x-show="!isRoot" @click="directoryUp()" >
					<div class="file-item-icon file-item-level-up bi-arrow-90deg-up text-secondary"></div>
					<a class="file-item-name">#request.i18n.getValue("Go up")#</a>
				</div>
				<div class="file-item" x-show="loading">
					<div class="file-item-icon text-secondary">
						<div class="spinner-border" role="status">
							<span class="sr-only">#request.i18n.getValue("Loading")#...</span>
						</div>
					</div>
				</div>
				<template x-if="directories">
				<template x-for="dir in directories" :key="dir.name">
					<div class="file-item">
						<div class="file-item-icon bi bi-folder text-secondary" @click="directoryIn( dir )"></div>
						<a class="file-item-name" x-text="dir.name"  @click="directoryIn( dir )">
						</a>
						<div class="file-item-actions btn-group">
							<div class="dropdown me-1">
								<button type="button" class="btn btn-default btn-sm rounded-pill icon-btn borderless md-btn-flat hide-arrow dropdown-toggle" data-bs-toggle="dropdown"><i class="ion ion-ios-more"></i></button>
								<ul class="dropdown-menu py-0" aria-labelledby="dropdownMenuOffset">
									<li><a class="dropdown-item" @click="openRenameDir( dir.name )">#request.i18n.getValue("Rename")#</a></li>
									<li><a class="dropdown-item rounded-bottom" @click="deleteDir( dir.name )">#request.i18n.getValue("Delete")#</a></li>
								</ul>
							</div>
						</div>
					</div>
				</template>
			</template>
				<template x-if="files">
					<template x-for="item in files" :key="item.name">
					<div class="file-item">
						<template x-if="item.isImage">
							<img class="file-item-img" :src="item.url">
							<div :style="'background-image: url(' && item.url && ')'"></div>
						</template>
						<template x-if="!item.isImage">
							<div class="file-item-icon bi text-gray-600" :class="item.icon" ></div>
						</template>
						<div class="file-item-name" x-text="item.name"></div>
						<div class="file-item-actions btn-group">
							<div class="dropdown me-1">
								<button type="button" class="btn btn-default btn-sm rounded-pill icon-btn borderless md-btn-flat hide-arrow dropdown-toggle" data-bs-toggle="dropdown"><i class="ion ion-ios-more"></i></button>
								<ul class="dropdown-menu py-0" aria-labelledby="dropdownMenuOffset">
									<!---<li>  <a class="dropdown-item rounded-top" href="javascript:void(0)">Rename</a></li>
									<li><a class="dropdown-item" href="javascript:void(0)">Move</a></li>
									<li><a class="dropdown-item" href="javascript:void(0)">Copy</a></li>
									--->
									<li><a class="dropdown-item rounded-bottom" @click="deleteFile( item.name )">#request.i18n.getValue("Delete")#</a></li>
								</ul>
							</div>
						</div>
					</div>
				</template>
				</template>
			</div>
		</div>
	</div>
	<div class="modal fade" id="uploadModal" tabindex="-1" role="dialog">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title" x-text="uploadComponent.uploadTitle"></h5>
				<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			</div>
			<div class="modal-footer">
				<button class="btn btn-primary" x-show="uploadComponent.uploading" type="button" disabled>
					<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
					#request.i18n.getValue("Uploading")#...
				</button>
				<button @click="upload();" x-show="!uploadComponent.uploading" class="btn btn-primary">#request.i18n.getValue("Upload")#</button>
				<button @click="cancelUpload()" type="button" x-show="uploadComponent.uploading" class="btn btn-secondary">#request.i18n.getValue("Cancel upload")#</button>
			</div>
		</div>
	</div>
</div>
	<div class="modal fade" id="createFolderModal" tabindex="-1" role="dialog">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" x-text="createModel.title"></h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				</div>
				<div class="modal-body">
					<div class="container">
						<div class="row">
							<div class="col">
								<div class="mb-3 mt-3">
									<div class="form-group mb-3">
										<input  class="form-control" type="text" name="folder_name" id="folder_name" placeholder="Enter folder name" x-model="createModel.input" @keyup.enter="createDir()"/>
									</div>
								</div>
								<template class="d-flex justify-content-end align-items-center" x-if="createModel.loading">
									<span class="me-3 text-gray-500 fs-6">#request.i18n.getValue("Creating folder")#...</span>
									<div class="spinner-border" role="status">
										<span class="sr-only">#request.i18n.getValue("Creating folder")#...</span>
									</div>
								</template>
								<div id="alert_wrapper" x-show="createModel.alertActive">
									<div id="alert" class="alert fade show" role="alert" :class="createModel.alertClass">
										<span x-text="createModel.alertMessage"></span>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<button @click="createDir()" class="btn btn-primary">#request.i18n.getValue("Create")#</button>
				</div>
			</div>
		</div>
	</div>
	<div class="modal fade" id="renameFolderModal" tabindex="-1" role="dialog">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title" x-text="renameModel.title"></h5>
						<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
					</div>
					<div class="modal-body">
						<div class="container">
							<div class="row">
								<div class="col">
									<div class="mb-3 mt-3">
										<div class="form-group mb-3">
											<input  class="form-control" type="text" name="folder_name" id="folder_name" placeholder="Enter new folder name" x-model="renameModel.input" @keyup.enter="renameDir()"/>
										</div>
									</div>
									<template class="d-flex justify-content-end align-items-center" x-if="renameModel.loading">
										<span class="me-3 text-gray-500 fs-6">#request.i18n.getValue("Updating folder")#...</span>
										<div class="spinner-border" role="status">
											<span class="sr-only">#request.i18n.getValue("Updating folder")#...</span>
										</div>
									</template>
									<div id="alert_wrapper" x-show="renameModel.alertActive">
										<div id="alert" class="alert fade show" role="alert" :class="renameModel.alertClass">
											<span x-text="renameModel.alertMessage"></span>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div class="modal-footer">
						<button @click="renameDir()" class="btn btn-primary">#request.i18n.getValue("Rename")#</button>
					</div>
				</div>
			</div>
		</div>
</div>

	<script type="text/javascript">
		function data() {
			return {
				pathArray: [{name: 'Home', path: '', fullpath: '', isRoot: true}],
				searchValue: '',
				path: '',
				directories: null,
				loading: false,
				files: null,
				isRoot: true,
				currentDir: null,
				createModel: {
					title: 'Create folder in /',
					input: '',
					loading: false,
					alertActive: false,
					alertMessage: '',
					alertClass: '',
				},
				renameModel: {
					title: 'Rename folder',
					input: '',
					loading: false,
					alertActive: false,
					alertMessage: '',
					alertClass: '',
					currentDir: ''
				},
				highlight: false,
				message: 'Drag & drop file here',
				uploadFiles: [],
				init() {
					this.currentDir = this.pathArray[0];
					this.fetchData();
					this.uploadComponent.input = document.getElementById("file_input");
				},
				async handleDrop(e) {
					this.highlight = false;
					const droppedFiles = Array.from(e.dataTransfer.files);
					this.uploadFiles.push(...droppedFiles);

					// Calculate total bytes
					this.uploadComponent.totalBytes = droppedFiles.reduce((sum, f) => sum + f.size, 0);
					this.processQueue();
				},
				directoryIn(dir) {
					this.fetchData(dir.fullpath);
					this.pathArray.push(dir);
					this.currentDir = dir;
					this.isRoot = dir.fullpath == '';
				},
				directoryGo(dir) {
					while (this.pathArray.pop().fullpath != dir.fullpath) ;
					this.directoryIn(dir);
				},
				fetchData(path = this.path) {
					this.path = path;
					this.uploadComponent.uploadTitle = 'Upload file in ' + (this.path != '' ? this.path : '/');
					this.createModel.title = 'Create folder in ' + (this.path != '' ? this.path : '/');
					this.loading = true;
					this.files = [];
					this.directories = [];
					fetch(
							`filemanager/actions.cfm?action=FILES&path=${this.path}`)
							.then((res) => res.json())
							.then((data) => {
								this.loading = false;
								if (data.status) {
									this.files = data.data;
									this.files.forEach(function (file) {
										if (iconLookup.hasOwnProperty(file.extension)) {
											file.icon = iconLookup[file.extension];
										} else
											file.icon = 'bi-file';
									});
								}
							});
					fetch(
							`filemanager/actions.cfm?action=DIRECTORIES&path=${this.path}`)
							.then((res) => res.json())
							.then((data) => {
								this.loading = false;
								if (data.status)
									this.directories = data.data;
							});
				},
				directoryUp() {
					this.pathArray.pop();
					this.fetchData(this.pathArray[this.pathArray.length - 1].fullpath);
					this.isRoot = this.pathArray.length == 1;
				},
				deleteFile(name) {
					let formData = new FormData();
					formData.append('path', this.path);
					formData.append('name', name);
					fetch(`filemanager/actions.cfm?action=DELETE`, {
						body: formData,
						method: "post"
					})
							.then((res) => res.json())
							.then((data) => {
								this.loading = false;
								if (data.status) {
									this.refresh();
									notifySuccess(data.message);
								}

							});
				},
				isCurrent(dir) {
					return this.currentDir.fullpath == dir.fullpath;
				},
				refresh() {
					this.fetchData();
				},
				uploadComponent: {
					progressWidth: 0,
					progressLabel: '',
					uploading: false,
					uploadFilename: '',
					input: null,
					request: null,
					alertActive: false,
					alertMessage: '',
					alertClass: '',
					uploadTitle: '',
					totalBytes: 0,
					uploadedBytes: 0
				},
				upload() {
					// Reject if the file input is empty & throw alert
					if (!this.uploadComponent.input.value) {
						this.uploadComponent.alertActive = true;
						this.showAlert("No file selected", "warning")
						return;
					}

					this.uploadComponent.uploading = true;
					var self = this;
					var file = this.uploadComponent.input.files[0];
					var filename = file.name;

					var formData = new FormData();
					var request = new XMLHttpRequest();
					this.uploadComponent.request = request;//to be able to abort on cancel
					request.responseType = "json";

					// Get a reference to the filesize & set a cookie
					var filesize = file.size;
					document.cookie = `filesize=${filesize}`;

					// Append the file to the FormData instance
					formData.append("file", file);
					formData.append('filename', filename)

					// request progress handler
					request.upload.addEventListener("progress", function (e) {
						var percent_complete = (e.loaded / e.total) * 100;
						self.uploadComponent.progressWidth = Math.floor(percent_complete);
						self.uploadComponent.progressLabel = self.uploadComponent.progressWidth + '% uploaded';
					})

					// request error handler
					request.addEventListener("error", function (e) {
						self.resetUpload(true);
						self.showAlert(`Error uploading file`, "warning");
					});

					// request load handler (transfer complete)
					request.addEventListener("load", function (e) {
						if (request.status == 200) {
							if (request.response.status) {
								self.resetUpload();
								self.fetchData();
							} else {
								self.resetUpload(true);
								self.showAlert(request.response.message, "danger");
							}
						} else {
							self.resetUpload(true);
							self.showAlert(`Error uploading file`, "danger");
						}
					});

					this.uploadComponent.alertActive = false;
					// Open and send the request
					request.open("post", 'filemanager/actions.cfm?action=UPLOAD&path=' + this.path);
					request.send(formData);
				},
				resetUpload(soft = false) {
					this.uploadComponent.uploading = false;
					if (!soft) {
						this.uploadComponent.input.value = null;
						this.uploadComponent.alertActive = false
					}
					this.uploadComponent.request = null;
					this.uploadComponent.totalBytes = 0;
					this.uploadComponent.uploadedBytes = 0;
					this.uploadComponent.progressLabel = '';
					this.uploadComponent.progressWidth = 0;
					this.uploadFiles = [];
				},
				cancelUpload() {
					this.uploadComponent.request.abort();
					this.resetUpload();
				},
				showAlert(message, className) {
					this.uploadComponent.alertActive = true;
					this.uploadComponent.alertMessage = message;
					this.uploadComponent.alertClass = 'alert-' + className;
				},
				fileInputChange() {
					if (this.uploadComponent.input.value) {
						//directly upload
						this.upload();
						this.uploadComponent.alertActive = false;
					}
				},
				createDir() {
					this.createModel.loading = true;
					this.createModel.alertActive = false
					let formData = new FormData();
					formData.append('name', this.createModel.input);
					formData.append('path', this.path);
					fetch('filemanager/actions.cfm?action=CREATE_DIR', {
						body: formData,
						method: "post"
					})
							.then((res) => res.json())
							.then((data) => {
								this.createModel.loading = false;
								if (data.status) {
									this.refresh();
									this.createModel.input = '';
									this.createModel.alertActive = false
									$('##createFolderModal').modal('hide');
									notifySuccess(data.message);
								} else {
									this.showDirAlert(data.message, "danger");
								}
							});

				},
				openRenameDir(dir) {
					this.renameModel.currentDir = dir;
					this.renameModel.title = `Rename folder ${this.path}/${dir}`;
					$('##renameFolderModal').modal('show');
					this.renameModel.input = dir;
				},
				renameDir() {
					///this.renameModel.loading = true;
					this.renameModel.alertActive = false
					let formData = new FormData();
					formData.append('newname', this.renameModel.input);
					formData.append('path', this.path);
					formData.append('name', this.renameModel.currentDir);
					fetch('filemanager/actions.cfm?action=RENAME_DIR', {
						body: formData,
						method: "post"
					})
							.then((res) => res.json())
							.then((data) => {
								this.renameModel.loading = false;
								if (data.status) {
									this.refresh();
									this.renameModel.input = '';
									this.renameModel.alertActive = false
									$('##renameFolderModal').modal('hide');
									notifySuccess(data.message);
								} else {
									this.showDirAlert(data.message, "danger");
								}
							});
				},
				deleteDir(dir = '') {
					let isCurrent = false;
					if (dir.length == 0) {
						dir = this.path;
						isCurrent = true;
					} else {
						dir = this.path + "/" + dir;
					}
					swalWithBootstrapButtons.fire({
						title: "Are you sure?",
						text: "This folder and its contents will be deleted",
						icon: "warning",
						showCancelButton: true,
						confirmButtonText: "Yes, delete it!",
						cancelButtonText: "No",
						reverseButtons: true
					}).then((result) => {
						if (result.isConfirmed) {
							this.deleteDirConfirmed(dir, isCurrent);
						}
					});
				},
				deleteDirConfirmed(dir, isCurrent) {
					let formData = new FormData();
					formData.append('path', dir);
					fetch('filemanager/actions.cfm?action=DELETE_DIR', {
						body: formData,
						method: "post"
					})
							.then((res) => res.json())
							.then((data) => {
								this.createModel.loading = false;
								if (data.status) {
									if (isCurrent) {
										this.directoryUp();
									}
									this.refresh();
									this.createModel.input = '';
									this.createModel.alertActive = false
									$('##createFolderModal').modal('hide');
									notifySuccess(data.message);
								} else {
									notifyFailure(data.message);
								}
							});
				},
				showDirAlert(message, className) {
					this.createModel.alertActive = true;
					this.createModel.alertMessage = message;
					this.createModel.alertClass = 'alert-' + className;
				},
				async processQueue() {
					for (let file of this.uploadFiles) {
						await this.uploadFile(file);
					}
					this.resetUpload(true);
				},
				uploadFile(file) {
					var self = this;
					return new Promise((resolve, reject) => {
						self.uploadComponent.uploading = true;
						var filename = file.name;

						var formData = new FormData();
						var request = new XMLHttpRequest();
						self.uploadComponent.request = request;//to be able to abort on cancel
						request.responseType = "json";

						// Get a reference to the filesize & set a cookie
						var filesize = file.size;
						document.cookie = `filesize=${filesize}`;

						// Append the file to the FormData instance
						formData.append("file", file);
						formData.append('filename', filename)

						request.upload.addEventListener('progress', e => {
							if (e.lengthComputable) {
								// Add this file's uploaded bytes to the total
								const currentUploaded = e.loaded;
								var percent_complete = Math.round(((self.uploadComponent.uploadedBytes + currentUploaded) / self.uploadComponent.totalBytes) * 100);
								self.uploadComponent.progressWidth = Math.floor(percent_complete);
								self.uploadComponent.progressLabel = self.uploadComponent.progressWidth + '% uploaded';

							}
						});

						request.onreadystatechange = () => {
							if (request.readyState === 4) {
								if (request.status >= 200 && request.status < 300) {
									//self.uploadComponent.uploadedBytes += file.size;
									resolve();
								} else {
									console.error('Upload failed for', file.name);
									reject();
								}
							}
						};
						request.addEventListener("load", function (e) {
							if (request.status == 200) {
								if (request.response.status) {
									self.fetchData();
								} else {
									self.showAlert(request.response.message, "danger");
								}
							} else {
								self.showAlert(`Error uploading file`, "danger");
							}
						});

						request.open("post", 'filemanager/actions.cfm?action=UPLOAD&path=' + this.path);
						request.send(formData);
					});
				}
			}
		}
	</script>
	</cfoutput>
</cf_layout>
