component {
    function create( admin, authorId, assetPath, email, category, name ){
        var basepage = {
            publish = true,
            authorId = authorId,
            allowComments = false,
            content = "<p>Donec eget ex magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque venenatis dolor imperdiet dolor mattis sagittis. Praesent rutrum sem diam, vitae egestas enim auctor sit amet. Pellentesque leo mauris, consectetur id ipsum sit amet, fergiat. Pellentesque in mi eu massa lacinia malesuada et a elit. Donec urna ex, lacinia in purus ac, pretium pulvinar mauris. Nunc lorem mauris, fringilla in aliquam at, euismod in lectus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur sapien risus, commodo eget turpis at, elementum convallis enim turpis, lorem ipsum dolor sit amet nullam.</p>"
        };

        var featured = { 'key' = 'featured', name = 'Featured Page', value = '1' };

        admin.saveTemplateBlocks( 'home', deserializeJSON('[{"values":{"image":"#assetPath#images/profile.jpg","subtitle":"Hello, I''m #name#","title":"I create marketing strategies for your business that get results."},"id":"hero","active":"1"},{"values":{"text":"Lorem ipsum dolor sit amet consectetur adipisicing elit. Repellendus iste ipsam quod repellat. Hic tempora ullam aperiam ipsum optio magni vel inventore voluptatibus nisi maiores laboriosam fuga iure, velit eligendi ab vero minima? Quae ducimus ab dignissimos iure, eos consequatur est deleniti cum id aliquid neque.\r\n\r\nAutem tenetur commodi maiores. Lorem ipsum dolor sit, amet consectetur adipisicing elit. Est eligendi fugit, facilis velit reiciendis iure laudantium. Praesentium repellat corrupti dolor sit sint obcaecati. Modi aut quo molestiae a explicabo maiores necessitatibus nemo repellendus architecto? Corrupti numquam ullam nostrum, eveniet at doloribus blanditiis aliquid a est porro aspernatur pariatur culpa soluta nesciunt odio quasi maxime debitis illum.","button-url":"","subtitle":"About","title":"An inspiring headline about yourself.","button-label":"Work with me"},"id":"text","active":"1"},{"values":{"text":"Lorem ipsum dolor sit amet consectetur adipisicing elit. Laborum suscipit debitis quam dignissimos veritatis atque pariatur magnam obcaecati fugit reprehenderit vel numquam facere esse est deserunt, perferendis commodi voluptatem similique.","button-url":"","subtitle":"Expertise","title":"My key areas of expertise.","button-label":"View All Services"},"id":"featured-pages","active":"1"},{"values":{"text":"Lorem ipsum dolor sit amet consectetur adipisicing elit. Porro, numquam molestiae vel quaerat quas facilis voluptates rerum aspernatur quam voluptatem ea, vitae illo, omnis minus vero minima maiores quia nihil incidunt provident debitis ab qui quasi. Iure unde numquam in nulla praesentium nesciunt dolore exercitationem, odit expedita minima quisquam ullam ex. Aut perferendis vel consectetur modi esse. Temporibus reprehenderit alias magni atque repellat aspernatur voluptates, accusantium pariatur libero ad nesciunt illum labore facere. Earum iure consequatur cumque omnis maiores optio.","intro":"Quibusdam quis autem voluptatibus earum vel ex error ea. Lorem ipsum dolor sit amet consectetur adipisicing elit. Laborum suscipit debitis quam dignissimos veritatis atque pariatur magnam obcaecati fugit reprehenderit vel numquam facere esse est deserunt, perferendis commodi voluptatem similique.","subtitle":"Clients","title":"I have had the privilege of working with these incredible brands."},"id":"text-2","active":"1"},{"values":{"items":
            [{"url":"https://mangoblog.org","image":"#assetPath#images/clients/cactus.svg"},
            {"url":"https://eprofessor.com","image":"#assetPath#images/clients/chain.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/clients/flash.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/clients/hitech.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/clients/pinpoint.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/clients/proline.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/clients/rise.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/clients/terra.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/clients/vision.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/clients/volume.svg"},
            ]
            },"id":"logos","active":"1"},{"values":{"items":[
            {"photo":"#assetPath#images/avatars/user-01.jpg","text":"uibusdam quis autem voluptatibus earum vel ex error ea. Lorem ipsum dolor sit amet consectetur adipisicing elit. Laborum suscipit debitis quam dignissimos veritatis atque pariatur magnam obcaecati fugit reprehenderit vel numquam fa","name":"josh","title":"company y"},
              {"photo":"#assetPath#images/avatars/user-02.jpg","text":"The logging level is configured in the config.cfm in the node “logging”, in the entry “level”. It is set to “warning” by default. If you make a change to this setting, you need to go reload the configuration. If you wish to turn logging off, use “off” as the logging level.","name":"Andrew Smith","title":"company x"},

 {"photo":"#assetPath#images/avatars/user-03.jpg","text":"Mango Blog comes with a logging mechanism that is used to log failures, warnings or simply to debug plugins or other install issues.","name":"Daniel Ktr","title":"company x"},

        {"photo":"#assetPath#images/avatars/user-04.jpg","text":"By default, Mango will log certain failures (at this moment only plugin failures are logged) with log level “warning” or “error”. These logs are located in the database, in the table “log” (with your custom prefix).","name":"Juan Smith","title":"company x"}
,
    {"photo":"#assetPath#images/avatars/user-05.jpg","text":"The logging level is configured in the config.cfm in the node “logging”, in the entry “level”. It is set to “warning” by default. If you make a change to this setting, you need to go reload the configuration. If you wish to turn logging off, use “off” as the logging level.","name":"Andrew Smith","title":"company x"}
            ]

            },"id":"testimonials","active":"1"},{"values":{"text":"Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis rem, esse doloribus sint eaque at debitis enim vitae minus expedita ratione dignissimos sit nostrum optio sequi. Ipsa at beatae quam.\r\n\r\n","button-url":"","title":"Get started with a consultation today.","button-label":"Call me"},"id":"call-to-action","active":"1"},{"values":{"subtitle":"Recent Articles","title":"Latest articles from my blog"},"id":"posts","active":"1"}]') );

        //pages, posts and images
        var post = {
            title = "This is a headline",
            excerpt = "<p>This is a post with a featured image and a video. Aenean ornare velit lacus varius enim ullamcorper proin aliquam
facilisis ante sed etiam magna interdum congue. Lorem ipsum dolor
amet nullam sed etiam veroeros.</p>",
            content = "<p>Donec eget ex magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque venenatis dolor imperdiet dolor mattis sagittis. Praesent rutrum sem diam, vitae egestas enim auctor sit amet. Pellentesque leo mauris, consectetur id ipsum sit amet, fergiat. Pellentesque in mi eu massa lacinia malesuada et a elit. Donec urna ex, lacinia in purus ac, pretium pulvinar mauris. Nunc lorem mauris, fringilla in aliquam at, euismod in lectus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur sapien risus, commodo eget turpis at, elementum convallis enim turpis, lorem ipsum dolor sit amet nullam.</p>",
            publish = true,
            authorId = authorId,
            allowComments = true,
            postedOn = dateadd( 'd', -1, now() ),
            customFields = {  'image' = { 'key' = 'image', name = 'Featured Image', value = '#assetPath#images/img1.jpg' }
            },
            categories = [ category.getId() ]
        };

        var result = admin.newPost( argumentcollection = post );

        for ( var i = 2; i LTE 5; i++) {
            post = {
                title = "Sed magna ipsum faucibus",
                excerpt = "<p>Donec eget ex magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque venenatis dolor imperdiet dolor mattis sagittis magna etiam.</p>",
                content = basepage.content,
                publish = true,
                authorId = authorId,
                allowComments = true,
                postedOn = dateadd('d', -#i#, now()),
                customFields = { 'image' = { 'key' = 'image',
                    name = 'Featured Image', value = '#assetPath#images/img#i#.jpg' } },
                categories = [ category.getId() ]
            };

            result = admin.newPost(argumentcollection = post);
        }

        var post = duplicate( basepage );
        post.title = "Journal";
        post.template = 'blog.cfm';
        post.sortOrder = 4;
        result = admin.newPage( argumentcollection = post );

        //ABOUT
        post.title = "About";
        post.template = 'page_blocks.cfm';
        post.sortOrder = 1;
        post.content = '<p><img class="largeimage" src="#assetPath#images/img1.jpg"></p><h2>How I Got Here</h2><p>Eaque temporibus culpa perferendis expedita assumenda mollitia magnam. Lorem ipsum dolor sit amet consectetur adipisicing elit facilis voluptates voluptatum animi numquam quas ea praesentium quaerat maxime sunt odit inventore itaque est et autem sequi nulla. Distinctio obcaecati nesciunt asperiores dolorum tenetur voluptates, nemo alias doloremque. Quos cumque ipsum laudantium odio vero aut odit nostrum aliquam? Nostrum in facilis, minus fuga quasi voluptas explicabo possimus incidunt, expedita tempora eius rem nobis sequi. Doloribus esse sint suscipit quam nisi blanditiis voluptate explicabo.</p>';

        var customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"values":{},"id":"header","active":"1"},{"values":{"text":"Lorem ipsum dolor sit amet consectetur, adipisicing elit. Alias eos quas blanditiis, quos sint nostrum fugit aperiam inventore optio itaque molestias corporis, ipsa tenetur eligendi nihil iste porro, natus culpa consequuntur? Maxime, corporis tempore. Sed tenetur veritatis velit recusandae eum, molestiae voluptate ducimus laudantium esse illo doloribus atque eligendi deleniti iusto.","title":"Some inspiring words to describe yourself"},"id":"text-3","active":"1"},{"values":{},"id":"content","active":"1"},{"values":{"items":[{"text":"Lorem ipsum dolor sit amet consectetur adipisicing elit. Mollitia accusamus consectetur adipisicing elit excepturi corrupti nam quae exercitationem cupiditate, provident ipsa delectus vero possimus reprehenderit quas ut officiis tempora voluptatum quibusdam consectetur commodi.","title":"Consectetur"},{"text":"Molestias, autem impedit culpa dolores excepturi, quidem unde ducimus, rerum commodi deserunt earum, minus voluptatum. Lorem ipsum dolor sit amet consectetur, adipisicing elit. Saepe doloremque provident quas quae exercitationem laboriosam.","title":"Adipisicing"},{"text":"Mollitia accusamus consectetur. Lorem ipsum dolor sit amet consectetur adipisicing elit. Adipisicing elit excepturi corrupti nam quae exercitationem cupiditate, provident ipsa delectus vero possimus reprehenderit quas ut officiis tempora voluptatum quibusdam consectetur commodi!","title":"Doloremque"},{"text":"Lorem ipsum dolor sit amet consectetur, adipisicing elit. Saepe doloremque provident quas quae exercitationem laboriosam. Molestias, autem? Impedit culpa dolores excepturi, quidem unde ducimus, rerum commodi deserunt earum, minus voluptatum?","title":"Assumenda"}],"title":"My Values & Beliefs"},"id":"text-4","active":"1"},{"values":{"items":[{"photo":"#assetPath#images/avatars/user-01.jpg","text":"Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. Voluptas tempore rem. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Nisi dolores quaerat fuga rem nihil nostrum. Laudantium quia consequatur molestias.","name":"John Rockefeller","title":"Standard Oil Co."},{"photo":"#assetPath#images/avatars/user-04.jpg","text":"Voluptas tempore rem. Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Nisi dolores quaerat fuga rem nihil nostrum. Laudantium quia consequatur molestias.","name":"Andrew Carnegie","title":"Carnegie Steel Co."},{"photo":"#assetPath#images/avatars/user-06.jpg","text":"Nisi dolores quaerat fuga rem nihil nostrum. Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. \r\nVoluptas tempore rem. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Laudantium quia consequatur molestias.","name":"Henry Ford","title":"Ford Motor Co."},{"photo":"#assetPath#images/avatars/user-05.jpg","text":"Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. Voluptas tempore rem. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Nisi dolores quaerat fuga rem nihil nostrum. Laudantium quia consequatur molestias.","name":"John Morgan","title":"JP Morgan & Co."}],"subtitle":"Testimonials","title":"Reviews From Real Clients"},"id":"testimonials-2","active":"1"},{"values":{"text":"Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis rem, esse doloribus sint eaque at debitis enim vitae minus expedita ratione dignissimos sit nostrum optio sequi. Ipsa at beatae quam.","button-url":"##","title":"Get started with a consultation today.","button-label":"Let''s Work Together"},"id":"call-to-action","active":"1"}]' };

        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), customFields );
        ///admin.setPageCustomField( result.newPage.getId(), {'key' = 'featured',  name = 'Is Page featured?', value = 0 } );

        //CONTACT
        post.title = "Contact";
        post.sortOrder = 5;

        customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"values":{},"id":"header","active":"1"},{"values":{"text":"Lorem ipsum dolor sit amet consectetur, adipisicing elit. Alias eos quas blanditiis, quos sint nostrum fugit aperiam inventore optio itaque molestias corporis, ipsa tenetur eligendi nihil iste porro, natus culpa consequuntur. Maxime, corporis tempore. Sed tenetur veritatis velit recusandae eum, molestiae voluptate ducimus laudantium esse illo.","title":"Let''s take your business to the next level."},"id":"text-3","active":"1"},{"values":{"form-action":"","title":"Contact us"},"id":"contact","active":"1"},{"values":{"items":[{"photo":"#assetPath#images/avatars/user-01.jpg","text":"Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. Voluptas tempore rem. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Nisi dolores quaerat fuga rem nihil nostrum. Laudantium quia consequatur molestias.","name":"John Rockefeller","title":"Standard Oil Co."},{"photo":"#assetPath#images/avatars/user-04.jpg","text":"Voluptas tempore rem. Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Nisi dolores quaerat fuga rem nihil nostrum. Laudantium quia consequatur molestias.","name":"Andrew Carnegie","title":"Carnegie Steel Co."},{"photo":"#assetPath#images/avatars/user-06.jpg","text":"Nisi dolores quaerat fuga rem nihil nostrum. Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. \r\nVoluptas tempore rem. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Laudantium quia consequatur molestias.","name":"Henry Ford","title":"Ford Motor Co."}],"subtitle":"Testimonials","title":"Reviews From Real Clients"},"id":"testimonials-2","active":"1"},{"values":{"items":[]},"id":"features","active":false},{"values":{},"id":"content","active":false},{"values":{"text":"","button-url":"##","title":"","button-label":"Call now"},"id":"call-to-action","active":false},{"values":{"items":[],"title":""},"id":"text-4","active":false},{"values":{"items":[],"title":""},"id":"progress","active":false}]'
        };

        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), customFields );

        post.title = "Services";
        post.sortOrder = 3;
        post.content = '<p><h2>How I Got Here</h2><p>Eaque temporibus culpa perferendis expedita assumenda mollitia magnam. Lorem ipsum dolor sit amet consectetur adipisicing elit facilis voluptates voluptatum animi numquam quas ea praesentium quaerat maxime sunt odit inventore itaque est et autem sequi nulla. Distinctio obcaecati nesciunt asperiores dolorum tenetur voluptates, nemo alias doloremque. Quos cumque ipsum laudantium odio vero aut odit nostrum aliquam? Nostrum in facilis, minus fuga quasi voluptas explicabo possimus incidunt, expedita tempora eius rem nobis sequi. Doloribus esse sint suscipit quam nisi blanditiis voluptate explicabo.</p>';

        customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"values":{},"id":"header","active":"1"},{"values":{},"id":"content","active":false},{"values":{"text":"Lorem ipsum dolor sit amet consectetur, adipisicing elit. Alias eos quas blanditiis, quos sint nostrum fugit aperiam inventore optio itaque molestias corporis, ipsa tenetur eligendi nihil iste porro, natus culpa consequuntur? Maxime, corporis tempore. Sed tenetur veritatis velit recusandae eum, molestiae voluptate ducimus laudantium esse illo doloribus atque eligendi deleniti iusto.","title":"High-impact services to help your business"},"id":"text-3","active":"1"},{"values":{"items":[{"text":"Rerum quam quos. Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam. Cumque ducimus laborum doloribus facere maxime vel earum quidem enim suscipit.","items":[{"text":"Cumque Ducimus"},{"text":"Maxime Vel"},{"text":"Asperiores"}],"title":"Digital Marketing"},{"text":"Quibusdam quis autem voluptatibus earum vel ex error ea magni. Rerum quam quos. Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam.","items":[{"text":"Lorem Ipsum"},{"text":"voluptatibus Earum"},{"text":"Mollitia"}],"title":"Social Media Marketing"},{"text":"Rerum quam quos. Quibusdam quis autem voluptatibus earum vel ex error ea magni. Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam.","items":[{"text":"Eaque velit"},{"text":"Voluptatibus Earum"},{"text":"Eligendi Et"}],"title":"Content Marketing"},{"text":"Eaque velit eligendi ut magnam.Rerum quam quos. Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Cumque ducimus laborum doloribus facere maxime vel earum quidem enim suscipit.","items":[{"text":"Cumque Ducimus"},{"text":"Eligendi Et"},{"text":"Voluptatibus Earum"}],"title":"Paid Advertising"},{"text":"Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam. Cumque ducimus laborum doloribus facere maxime vel earum quidem enim suscipit.","items":[{"text":"Voluptatibus Earum"},{"text":"Cumque Ducimus"}],"title":"Search Engine Optimization"},{"text":"Quibusdam quis autem voluptatibus earum vel ex error ea magni. Rerum quam quos. Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam.","items":[{"text":"Eligendi Et"},{"text":"Mollitia"},{"text":"Voluptatibus Earum"}],"title":"Advance Analytics"},{"text":"Rerum quam quos. Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam. Cumque ducimus laborum doloribus facere maxime vel earum quidem enim suscipit.","items":[{"text":"Doloribus"},{"text":"Suscipit"},{"text":"Eligendi Et"}],"title":"Email Marketing"},{"text":"Quibusdam quis autem voluptatibus earum vel ex error ea magni. Rerum quam quos. Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam.","items":[{"text":"Cumque Ducimus"},{"text":"Maxime Vel"}],"title":"Conversion Rate Optimization"},{"text":"Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam. Cumque ducimus laborum doloribus facere maxime vel earum quidem enim suscipit.","items":[{"text":"Suscipit"},{"text":"Voluptatem"}],"title":"Web Design"}]},"id":"features","active":"1"},
            {"values":{"items":[{"photo":"#assetPath#images/avatars/user-01.jpg","text":"Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. Voluptas tempore rem. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Nisi dolores quaerat fuga rem nihil nostrum. Laudantium quia consequatur molestias.","name":"John Rockefeller","title":"Standard Oil Co."},{"photo":"#assetPath#images/avatars/user-04.jpg","text":"Voluptas tempore rem. Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Nisi dolores quaerat fuga rem nihil nostrum. Laudantium quia consequatur molestias.","name":"Andrew Carnegie","title":"Carnegie Steel Co."},{"photo":"#assetPath#images/avatars/user-06.jpg","text":"Nisi dolores quaerat fuga rem nihil nostrum. Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. \r\nVoluptas tempore rem. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Laudantium quia consequatur molestias.","name":"Henry Ford","title":"Ford Motor Co."},{"photo":"#assetPath#images/avatars/user-05.jpg","text":"Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. Voluptas tempore rem. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Nisi dolores quaerat fuga rem nihil nostrum. Laudantium quia consequatur molestias.","name":"John Morgan","title":"JP Morgan & Co."}],"subtitle":"Testimonials","title":"Reviews From Real Clients"},"id":"testimonials-2","active":"1"},
            {"values":{"text":"Lorem ipsum dolor sit amet consectetur adipisicing elit. Laborum suscipit debitis quam dignissimos veritatis atque pariatur magnam obcaecati fugit reprehenderit vel numquam facere esse est deserunt, perferendis commodi voluptatem similique.","button-url":"","subtitle":"Expertise","title":"My key areas of expertise.","button-label":"View All Services"},"id":"featured-pages","active":"1"},
            {"values":{"text":"Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis rem, esse doloribus sint eaque at debitis enim vitae minus expedita ratione dignissimos sit nostrum optio sequi. Ipsa at beatae quam.","button-url":"##","title":"Get started with a consultation today.","button-label":"Let''s Work Together"},"id":"call-to-action","active":"1"},
            {"values":{"items":[],"title":""},"id":"text-4","active":false},{"values":{"items":[],"title":""},"id":"progress","active":false},{"values":{"form-action":"","title":""},"id":"contact","active":false}]'
        };

        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), customFields );

        var parent = result.newPage.getId();

        post.title = "Digital Marketing";
        post.sortOrder = 1;
        post.parentPage = parent;
        post.content = '<p><img class="largeimage" src="#assetPath#images/img3.jpg"></p><h2>Info about..</h2><p>Eaque temporibus culpa perferendis expedita assumenda mollitia magnam. Lorem ipsum dolor sit amet consectetur adipisicing elit facilis voluptates voluptatum animi numquam quas ea praesentium quaerat maxime sunt odit inventore itaque est et autem sequi nulla. Distinctio obcaecati nesciunt asperiores dolorum tenetur voluptates, nemo alias doloremque. Quos cumque ipsum laudantium odio vero aut odit nostrum aliquam? Nostrum in facilis, minus fuga quasi voluptas explicabo possimus incidunt, expedita tempora eius rem nobis sequi. Doloribus esse sint suscipit quam nisi blanditiis voluptate explicabo.</p>';
        post.excerpt = "<p>Quibusdam quis autem voluptatibus earum vel ex error ea magni. Rerum quam quos. Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam. Cumque ducimus laborum doloribus facere maxime vel earum quidem enim suscipit.</p>";

        customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"values":{},"id":"header","active":"1"},{"values":{},"id":"content","active":"1"},{"values":{"items":[{"number":"85","title":"Campaigns"},{"number":"95","title":"Content creation"}],"title":"Digital Skills"},"id":"progress","active":"1"},{"values":{"text":"","title":""},"id":"text-3","active":false},{"values":{"items":[]},"id":"features","active":false},{"values":{"items":[],"subtitle":"","title":""},"id":"testimonials-2","active":false},{"values":{"text":"","button-url":"##","title":"","button-label":"Call now"},"id":"call-to-action","active":false},{"values":{"items":[],"title":""},"id":"text-4","active":false},{"values":{"form-action":"","title":""},"id":"contact","active":false},{"values":{"text":"","button-url":"##","subtitle":"","title":"","button-label":"Register now"},"id":"featured-pages","active":false}]'
        };

        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), customFields );
        admin.setPageCustomField( result.newPage.getId(), featured );

        post.title = "Project Management";
        post.sortOrder = 2;
        post.parentPage = parent;
        customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"values":{},"id":"header","active":"1"},{"values":{},"id":"content","active":"1"},{"values":{"items":[{"number":"70","title":"Leadership"},{"number":"90","title":"Management"},{"number":"100","title":"Organization"}],"title":"People Skills"},"id":"progress","active":"1"},{"values":{"text":"","title":""},"id":"text-3","active":false},{"values":{"items":[]},"id":"features","active":false},{"values":{"items":[],"subtitle":"","title":""},"id":"testimonials-2","active":false},{"values":{"text":"","button-url":"##","title":"","button-label":"Call now"},"id":"call-to-action","active":false},{"values":{"items":[],"title":""},"id":"text-4","active":false},{"values":{"form-action":"","title":""},"id":"contact","active":false},{"values":{"text":"","button-url":"##","subtitle":"","title":"","button-label":"Register now"},"id":"featured-pages","active":false}]'
        };

        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), customFields );
        admin.setPageCustomField( result.newPage.getId(), featured );

        post.title = "Content Marketing";
        post.sortOrder = 3;
        post.parentPage = parent;

        customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"values":{},"id":"header","active":"1"},{"values":{},"id":"content","active":"1"},{"values":{"items":[{"number":"70","title":"Creativity"},{"number":"60","title":"Writing & Storytelling"},{"number":"80","title":"Visual Content"},{"number":"50","title":"Branding & Creative Strategy"}],"title":"Content"},"id":"progress","active":"1"},{"values":{"text":"","title":""},"id":"text-3","active":false},{"values":{"items":[]},"id":"features","active":false},{"values":{"items":[],"subtitle":"","title":""},"id":"testimonials-2","active":false},{"values":{"text":"","button-url":"##","title":"","button-label":"Call now"},"id":"call-to-action","active":false},{"values":{"items":[],"title":""},"id":"text-4","active":false},{"values":{"form-action":"","title":""},"id":"contact","active":false}]'
        };


        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), customFields );
        admin.setPageCustomField( result.newPage.getId(), featured );


        admin.saveSetting( 'site/info', 'menu-button-label', "Let's work together" );
        admin.removeSetting( 'site/info', 'logo' );
        admin.removeSetting( 'site/info', 'newsletter-enabled' );
        admin.removeSetting( 'site/info', 'newsletter-intro' );

        var b = admin.getBlog().clone();

        admin.editBlog( b.getTitle(), "Some good tagline",  "Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptas illum quasi facere libero, fugiat laboriosam possimus reprehenderit eveniet vero voluptatum fugit ad quis veritatis suscipit beatae incidunt perferendis tempore earum hic repellendus quisquam recusandae ipsa id esse. Nobis, aut deleniti. Lorem ipsum dolor sit amet consectetur, adipisicing elit. Facere ratione dignissimos.", b.getUrl(), 'monica' );

        return result;
    }
}