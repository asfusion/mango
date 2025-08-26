component {
    function create( admin, authorId, assetPath, email, category, name ){
        //pages, posts and images
        var post = {
            title = "This is a headline for a video post",
            excerpt = "<p>This is a post with a featured image and a video. Aenean ornare velit lacus varius enim ullamcorper proin aliquam
facilisis ante sed etiam magna interdum congue. Lorem ipsum dolor
amet nullam sed etiam veroeros.</p>",
            content = "<p>Donec eget ex magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque venenatis dolor imperdiet dolor mattis sagittis. Praesent rutrum sem diam, vitae egestas enim auctor sit amet. Pellentesque leo mauris, consectetur id ipsum sit amet, fergiat. Pellentesque in mi eu massa lacinia malesuada et a elit. Donec urna ex, lacinia in purus ac, pretium pulvinar mauris. Nunc lorem mauris, fringilla in aliquam at, euismod in lectus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur sapien risus, commodo eget turpis at, elementum convallis enim turpis, lorem ipsum dolor sit amet nullam.</p>",
            publish = true,
            authorId = authorId,
            allowComments = true,
            postedOn = dateadd( 'd', -1, now() ),
            customFields = {  'image' = { 'key' = 'image', name = 'Featured Image', value = '#assetPath#images/pic01.jpg' },
                    'video' = { 'key' = 'video', name = 'Video embed', value = '<iframe width="560" height="315" src="https://www.youtube.com/embed/imA0OQzDrFE?si=STJtrNCrkdW0mvZd" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>' },
                'entryType' = { 'key' = 'entryType', name = 'Entry Type', value = 'video' }
            },
            categories = [ category.getId() ]
        };

        var result = admin.newPost( argumentcollection = post );

        for ( var i = 2; i LTE 5; i++) {
            post = {
                title = "Sed magna ipsum faucibus",
                excerpt = "<p>Donec eget ex magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque venenatis dolor imperdiet dolor mattis sagittis magna etiam.</p>",
                content = "<p>Donec eget ex magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque venenatis dolor imperdiet dolor mattis sagittis. Praesent rutrum sem diam, vitae egestas enim auctor sit amet. Pellentesque leo mauris, consectetur id ipsum sit amet, fergiat. Pellentesque in mi eu massa lacinia malesuada et a elit. Donec urna ex, lacinia in purus ac, pretium pulvinar mauris. Nunc lorem mauris, fringilla in aliquam at, euismod in lectus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur sapien risus, commodo eget turpis at, elementum convallis enim turpis, lorem ipsum dolor sit amet nullam.</p>",
                publish = true,
                authorId = authorId,
                allowComments = true,
                postedOn = dateadd('d', -#i#, now()),
                categories = [ category.getId() ],
                customFields = { 'image' = { 'key' = 'image',
                    name = 'Featured Image', value = '#assetPath#images/pic0#i#.jpg' } }
            };

            result = admin.newPost(argumentcollection = post);
        }

        post.title = "About";
        result = admin.newPage( argumentcollection = post );
        return result;
    }
}