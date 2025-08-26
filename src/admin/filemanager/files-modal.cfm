	<div x-data="data" data-reflect-root="">
	<div class="container flex-grow-1 light-style container-p-y">
		<div class="small-top-bar mb-3">
			<ol class="breadcrumb text-big container-p-x py-3 m-0">
				<template x-for="crumb in pathArray">
					<li class="breadcrumb-item" :class="{ 'active': isCurrent(crumb) }">
						<a @click="directoryGo( crumb )" x-text="crumb.name" ></a>
					</li>
				</template>
			</ol>
			<div class="file-field">
				<div class="d-flex justify-content-xl-center ms-xl-3">
					<div class="d-flex">
						<input  class="form-control" type="file" name="file_input" id="file_input" :disabled="uploadComponent.uploading" @change="fileInputChange()">
						<button type="button" class="btn btn-primary mr-2"><i class="ion ion-md-cloud-upload"></i>&nbsp; Upload</button>
					</div>
				</div>
			</div>
		</div>
		<div id="progress_wrapper" x-show="uploadComponent.uploading">
			<label id="progress_status" x-text="uploadComponent.progressLabel"></label>
			<div class="progress mb-3">
				<div id="progress" class="progress-bar" role="progressbar" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" :style="`width: ${uploadComponent.progressWidth}%;`"></div>
			</div>
		</div>
		<div id="alert_wrapper" x-show="uploadComponent.alertActive">
			<div id="alert" class="alert fade show" role="alert" :class="uploadComponent.alertClass">
				<span x-text="uploadComponent.alertMessage"></span>
			</div>
		</div>
		<template x-if="createModel.isOpen">
			<div class="row g-3 form-group">
				<div class="col-sm-7">
					<input class="form-control" type="text" placeholder="New folder name" x-model="createModel.input" @keyup.enter="createDir()"/>
				</div>
				<div class="col-sm-4">
					<button class="btn btn-outline-primary">Submit</button>
				</div>
			</div>
		</template>

		 <div class="file-manager-container file-manager-col-view">

		<div class="file-item" x-show="!isRoot" @click="directoryUp()" >
			<div class="file-item-icon file-item-level-up bi-arrow-90deg-up text-secondary"></div>
			<a class="file-item-name">Go up</a>
		</div>
		<div class="file-item" x-show="loading">
			<div class="file-item-icon text-secondary">
				<div class="spinner-border" role="status">
					<span class="sr-only">Loading...</span>
				</div>
			</div>
		</div>
		<template x-if="directories">
			<template x-for="dir in directories" :key="dir.name">
				<div class="file-item">
					<div class="file-item-icon bi bi-folder text-secondary" @click="directoryIn( dir )"></div>
					<a class="file-item-name" x-text="dir.name"  @click="directoryIn( dir )">
					</a>
				</div>
			</template>
		</template>
		<template x-if="files">
			<template x-for="item in files" :key="item.name">
	<div class="file-item" @click="selectFile( item )" >
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
			<li><a class="dropdown-item rounded-bottom" @click="deleteFile( item.name )">Delete</a></li>
		</ul>
		</div>
		</div>
		</div>
		</template>
		</template>
	</div>
	</div>
	</div>
	</div>

	<script type="text/javascript">
		function data() {
			return {
				pathArray: [ { name: 'Home', path: '', fullpath: '', isRoot: true }],
				searchValue: '',
				path: '',
				directories: null,
				loading: false,
				files: null,
				isRoot: true,
				currentDir: null,
				createModel: {
					title: '',
					input: '',
					isOpen: false,
					loading: false,
					alertActive: false,
					alertMessage: '',
					alertClass: '',
				},
				init() {
					this.currentDir = this.pathArray[ 0 ];
					this.fetchData();
					this.uploadComponent.input = document.getElementById("file_input");
				},
				directoryIn( dir ){
					this.fetchData( dir.fullpath );
					this.pathArray.push( dir );
					this.currentDir = dir;
					this.isRoot = dir.fullpath == '';
				},
				directoryGo( dir ){
					while ( this.pathArray.pop( ).fullpath != dir.fullpath );
					this.directoryIn( dir );
				},
				fetchData(path = this.path) {
					this.path = path;
					this.loading = true;
					this.files = [];
					this.directories = [];
					this.uploadComponent.alertActive = false;

					fetch(
							`filemanager/actions.cfm?action=FILES&path=${this.path}`)
							.then((res) => res.json())
							.then((data) => {
								this.loading = false;
								if( data.status ) {
									this.files = data.data;
									this.files.forEach(function ( file ) {
										if ( iconLookup.hasOwnProperty( file.extension )){
											file.icon = iconLookup[ file.extension ];
										}
										else
											file.icon = 'fa-file';
									});
								}
							});
					fetch(
							`filemanager/actions.cfm?action=DIRECTORIES&path=${this.path}`)
							.then((res) => res.json())
							.then((data) => {
								this.loading = false;
								if( data.status )
									this.directories = data.data;
							});
				},
				directoryUp(){
					this.pathArray.pop( );
					this.fetchData( this.pathArray[ this.pathArray.length - 1 ].fullpath );
					this.isRoot = this.pathArray.length == 1;
				},
				deleteFile( name ){
					let formData = new FormData();
					formData.append( 'path', this.path );
					formData.append( 'name', name );
					fetch( `filemanager/actions.cfm?action=DELETE`,  {
						body: formData,
						method: "post" } )
					.then((res) => res.json())
					.then((data) => {
						this.loading = false;
						if( data.status ) {
							this.refresh();
						}

					});
				},
				isCurrent( dir ){
					return this.currentDir.fullpath == dir.fullpath;
				},
				refresh( ){
					this.fetchData();
				},
				selectFile( item ){
					<cfoutput>mango.assetSelectorCallback('#url.input#', item.relativePath );</cfoutput>
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
					uploadTitle: ''
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
						self.uploadComponent.progressWidth = Math.floor( percent_complete );
						self.uploadComponent.progressLabel = self.uploadComponent.progressWidth + '% uploaded';
					})

					// request error handler
					request.addEventListener("error", function (e) {
						self.resetUpload( true );
						self.showAlert(`Error uploading file`, "warning");
					});

					// request load handler (transfer complete)
					request.addEventListener("load", function (e) {
						if (request.status == 200) {
							if (request.response.status) {
								self.resetUpload();
								self.fetchData();
							} else {
								self.resetUpload( true );
								self.showAlert( request.response.message, "danger");
							}
						} else {
							self.resetUpload( true );
							self.showAlert(`Error uploading file`, "danger");
						}
					});

					this.uploadComponent.alertActive = false;
					// Open and send the request
					request.open("post", 'filemanager/actions.cfm?action=UPLOAD&path=' + this.path);
					request.send(formData);
				},
				resetUpload( soft = false ){
					this.uploadComponent.uploading = false;
					if ( !soft ) {
						this.uploadComponent.input.value = null;
						this.uploadComponent.alertActive = false
					}
					this.uploadComponent.request = null;
				},
				cancelUpload() {
					this.uploadComponent.request.abort();
					this.resetUpload();
				},
				showAlert( message, className ) {
					this.uploadComponent.alertActive = true;
					this.uploadComponent.alertMessage = message;
					this.uploadComponent.alertClass = 'alert-' + className;
				},
				fileInputChange() {
					if ( this.uploadComponent.input.value ) {
						//directly upload
						this.upload();
						this.uploadComponent.alertActive = false;
					}
				}
			}
		}

	</script>
