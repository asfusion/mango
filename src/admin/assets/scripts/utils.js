function array_move(arr, old_index, new_index) {
    if (new_index >= arr.length) {
        var k = new_index - arr.length + 1;
        while (k--) {
            arr.push(undefined);
        }
    }
    arr.splice(new_index, 0, arr.splice(old_index, 1)[0]);
    return arr; // for testing
};

const swalWithBootstrapButtons = Swal.mixin({
    customClass: {
        confirmButton: 'btn btn-primary me-3',
        cancelButton: 'btn btn-gray'
    },
    buttonsStyling: false
});

function notifySuccess( message ){
    swalWithBootstrapButtons.fire({
        title: "",
        text: message,
        icon: "success",
        timer: 1500
    });
};
function notifyFailure( message ){
    swalWithBootstrapButtons.fire({
        icon: "error",
        title: "Oops...",
        text: message
    });
}