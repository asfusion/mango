component {
    function create( admin, authorId, assetPath, email, category, name ){
        var basepage = {
            publish = true,
            authorId = authorId,
            allowComments = false,
            content = "<p>Donec eget ex magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque venenatis dolor imperdiet dolor mattis sagittis. Praesent rutrum sem diam, vitae egestas enim auctor sit amet. Pellentesque leo mauris, consectetur id ipsum sit amet, fergiat. Pellentesque in mi eu massa lacinia malesuada et a elit. Donec urna ex, lacinia in purus ac, pretium pulvinar mauris. Nunc lorem mauris, fringilla in aliquam at, euismod in lectus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur sapien risus, commodo eget turpis at, elementum convallis enim turpis, lorem ipsum dolor sit amet nullam.</p>"
        };

        var featured = { 'key' = 'subtitle', name = 'Subtitle', value = 'Page subtitle' };

        admin.saveTemplateBlocks( 'home', deserializeJSON('[{"values":{"subtitle":"Hello, I''m #name#","title":"We''re a creative group of people who design influential brands and digital experiences.", "text": "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat."},"id":"hero","active":"1"},
          {"values":{"items":[
          { "text": "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.","title":"Happy Customers", "number": "30+"},
          { "text": "Eleifend donec pretium vulputate sapien nec sagittis aliquam malesuada. Eu scelerisque felis imperdiet proin fermentum leo. Cursus turpis massa tincidunt.","title":"Hours Work", "number": "35+"},
          { "text": "Volutpat commodo sed egestas egestas fringilla phasellus faucibus scelerisque. Est velit egestas dui id ornare. Leo urna molestie at elementum.","title":"Coffee Drinks", "number": "41+"},
          { "text": "Nulla pharetra diam sit amet nisl suscipit adipiscing bibendum est. Quis risus sed vulputate odio ut. Lectus arcu bibendum at varius vel eu facilisis.","title":"Completed Projects", "number": "38+"}
          ]},"id":"stats","active":"1"},

          {"values":{"text":"Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam. Cumque ducimus laborum doloribus facere maxime vel earum quidem enim suscipit.",
          "items":[
            {"text":"Nemo cupiditate ab quibusdam quaerat impedit magni. Earum suscipit ipsum laudantium. Quo delectus est. Maiores voluptas ab sit natus veritatis ut. Debitis nulla cumque veritatis. Sunt suscipit voluptas ipsa in tempora esse soluta sint aliquam rhoncus elit.", "title":"Product Design", "icon":"#assetPath#images/icons/services/icon-product-design.svg"},
            {"text":"Nulla pharetra diam sit amet nisl suscipit adipiscing bibendum est. Quis risus sed vulputate odio ut. Lectus arcu bibendum at varius vel. Lorem ipsum dolor sit amet consectetur adipiscing elit pellentesque. In nulla posuere sollicitudin aliquam ultrices.", "title":"Branding", "icon":"#assetPath#images/icons/services/icon-branding.svg"},
             {"text":"Eleifend donec pretium vulputate sapien nec sagittis aliquam malesuada. Eu scelerisque felis imperdiet proin fermentum leo. Cursus turpis massa tincidunt dui. Quis commodo odio aenean sed adipiscing diam donec adipiscing. Congue mauris rhoncus elit.", "title":"Frontend Development", "icon":"#assetPath#images/icons/services/icon-frontend.svg"},
              {"text":"Nemo cupiditate ab quibusdam quaerat impedit magni. Earum suscipit ipsum laudantium. Quo delectus est. Maiores voluptas ab sit natus veritatis ut. Debitis nulla cumque veritatis. Sunt suscipit voluptas ipsa in tempora esse soluta sint donec adipiscing..", "title":"UX Research", "icon":"#assetPath#images/icons/services/icon-research.svg"}
            ],"title":"We’ve got everything you
need to launch and grow
your business", "subtitle":"What We Do"},"id":"features","active":"1"},

{"values":
{"items":[
{"text":"Lorem ipsum Occaecat do esse ex et dolor culpa nisi ex in magna consectetur nisi cupidat","url":"https://mangoblog.org","image":"#assetPath#images/portfolio/fuji.jpg","type":"Branding","title":"The Kinfolk"},{"text":"Lorem ipsum Occaecat do esse ex et dolor culpa nisi ex in magna consectetur nisi cupidat","url":"https://mangoblog.org","image":"#assetPath#images/portfolio/grayscale.jpg","type":"UI Design","title":"Grayscale"},
        {"text":"Lorem ipsum Occaecat do esse ex et dolor culpa nisi ex in magna consectetur nisi cupidat","url":"https://mangoblog.org","image":"#assetPath#images/portfolio/lamp.jpg","type":"Branding","title":"The Lamp"},
        {"text":"Lorem ipsum Occaecat do esse ex et dolor culpa nisi ex in magna consectetur nisi cupidat","url":"https://mangoblog.org","image":"#assetPath#images/portfolio/tulips.jpg","type":"Web Design ","title":"Caffein & Tulips"},
{"text":"Lorem ipsum Occaecat do esse ex et dolor culpa nisi ex in magna consectetur nisi cupidat","url":"https://mangoblog.org","image":"#assetPath#images/portfolio/minimalismo.jpg","type":"Web Design ","title":"Tropical"},
{"text":"Lorem ipsum Occaecat do esse ex et dolor culpa nisi ex in magna consectetur nisi cupidat","url":"https://mangoblog.org","image":"#assetPath#images/portfolio/woodcraft.jpg","type":"Branding","title":"Woodcraft"}],"subtitle":"Recent Works","title":"Here are some of our favorite projects we have done lately. Feel free to check them out."},"id":"portfolio","active":"1"},
{"values":{"items":
            [{"url":"https://mangoblog.org","image":"#assetPath#images/icons/clients/atom.svg"},
            {"url":"https://eprofessor.com","image":"#assetPath#images/icons/clients/dropbox.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/icons/clients/github.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/icons/clients/medium.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/icons/clients/messenger.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/icons/clients/redhat.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/icons/clients/spotify.svg"},
            {"url":"https://mangoblog.org","image":"#assetPath#images/icons/clients/steam.svg"}
            ], "title":"We''ve had the privilege with working with some of the largest and most iconic brands",
            },"id":"logos","active":"1"},

  {"values":{"video":"https://www.youtube.com/embed/hQM970Xm1Gs?si=XKjKX9K-iirkYsob"},"id":"video","active":"1"},

            {"values":{"items":[
            {"photo":"#assetPath#images/avatars/user-01.jpg","text":"uibusdam quis autem voluptatibus earum vel ex error ea. Lorem ipsum dolor sit amet consectetur adipisicing elit. Laborum suscipit debitis quam dignissimos veritatis atque pariatur magnam obcaecati fugit reprehenderit vel numquam fa","name":"josh","title":"company y"},
              {"photo":"#assetPath#images/avatars/user-02.jpg","text":"The logging level is configured in the config.cfm in the node “logging”, in the entry “level”. It is set to “warning” by default. If you make a change to this setting, you need to go reload the configuration. If you wish to turn logging off, use “off” as the logging level.","name":"Andrew Smith","title":"company x"},

 {"photo":"#assetPath#images/avatars/user-03.jpg","text":"Mango Blog comes with a logging mechanism that is used to log failures, warnings or simply to debug plugins or other install issues.","name":"Daniel Ktr","title":"company x"},

        {"photo":"#assetPath#images/avatars/user-04.jpg","text":"By default, Mango will log certain failures (at this moment only plugin failures are logged) with log level “warning” or “error”. These logs are located in the database, in the table “log” (with your custom prefix).","name":"Juan Smith","title":"company x"},
    {"photo":"#assetPath#images/avatars/user-05.jpg","text":"The logging level is configured in the config.cfm in the node “logging”, in the entry “level”. It is set to “warning” by default. If you make a change to this setting, you need to go reload the configuration. If you wish to turn logging off, use “off” as the logging level.","name":"Andrew Smith","title":"company x"} ]},"id":"testimonials","active":"1"},

            {"values":{"text":"Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis rem, esse doloribus sint eaque at debitis enim vitae minus expedita ratione dignissimos sit nostrum optio sequi. Ipsa at beatae quam.\r\n\r\n","button-url":"","title":"Get started with a consultation today.","button-label":"Call me"},"id":"call-to-action","active":"1"}]') );

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

        //CONTACT
        post.title = "Contact";
        post.sortOrder = 5;

        customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"values":{},"id":"header","active":"1"},{"values":{"text":"Lorem ipsum dolor sit amet consectetur, adipisicing elit. Alias eos quas blanditiis, quos sint nostrum fugit aperiam inventore optio itaque molestias corporis, ipsa tenetur eligendi nihil iste porro, natus culpa consequuntur. Maxime, corporis tempore. Sed tenetur veritatis velit recusandae eum, molestiae voluptate ducimus laudantium esse illo.","title":"Let''s take your business to the next level."},"id":"text-3","active":"1"},{"values":{"form-action":"","title":"Contact us"},"id":"contact","active":"1"},{"values":{"items":[{"photo":"#assetPath#images/avatars/user-01.jpg","text":"Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. Voluptas tempore rem. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Nisi dolores quaerat fuga rem nihil nostrum. Laudantium quia consequatur molestias.","name":"John Rockefeller","title":"Standard Oil Co."},{"photo":"#assetPath#images/avatars/user-04.jpg","text":"Voluptas tempore rem. Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Nisi dolores quaerat fuga rem nihil nostrum. Laudantium quia consequatur molestias.","name":"Andrew Carnegie","title":"Carnegie Steel Co."},{"photo":"#assetPath#images/avatars/user-06.jpg","text":"Nisi dolores quaerat fuga rem nihil nostrum. Molestiae incidunt consequatur quis ipsa autem nam sit enim magni. \r\nVoluptas tempore rem. Explicabo a quaerat sint autem dolore ducimus ut consequatur neque. Laudantium quia consequatur molestias.","name":"Henry Ford","title":"Ford Motor Co."}],"subtitle":"Testimonials","title":"Reviews From Real Clients"},"id":"testimonials-2","active":"1"},{"values":{"items":[]},"id":"features","active":false},{"values":{},"id":"content","active":false},{"values":{"text":"","button-url":"##","title":"","button-label":"Call now"},"id":"call-to-action","active":false}]'
        };

        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), customFields );

        post.title = "Services";
        post.sortOrder = 3;
        post.content = '<p></p>';

        customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"values":{},"id":"header","active":"1"},{"values":{},"id":"content","active":false},
              {"values":{"text":"Aut asperiores sit mollitia. Rem neque et voluptatem eos quia sed eligendi et. Eaque velit eligendi ut magnam. Cumque ducimus laborum doloribus facere maxime vel earum quidem enim suscipit.",
          "items":[
            {"text":"Nemo cupiditate ab quibusdam quaerat impedit magni. Earum suscipit ipsum laudantium. Quo delectus est. Maiores voluptas ab sit natus veritatis ut. Debitis nulla cumque veritatis. Sunt suscipit voluptas ipsa in tempora esse soluta sint aliquam rhoncus elit.", "title":"Product Design", "icon":"#assetPath#images/icons/services/icon-product-design.svg"},
            {"text":"Nulla pharetra diam sit amet nisl suscipit adipiscing bibendum est. Quis risus sed vulputate odio ut. Lectus arcu bibendum at varius vel. Lorem ipsum dolor sit amet consectetur adipiscing elit pellentesque. In nulla posuere sollicitudin aliquam ultrices.", "title":"Branding", "icon":"#assetPath#images/icons/services/icon-branding.svg"},
             {"text":"Eleifend donec pretium vulputate sapien nec sagittis aliquam malesuada. Eu scelerisque felis imperdiet proin fermentum leo. Cursus turpis massa tincidunt dui. Quis commodo odio aenean sed adipiscing diam donec adipiscing. Congue mauris rhoncus elit.", "title":"Frontend Development", "icon":"#assetPath#images/icons/services/icon-frontend.svg"},
              {"text":"Nemo cupiditate ab quibusdam quaerat impedit magni. Earum suscipit ipsum laudantium. Quo delectus est. Maiores voluptas ab sit natus veritatis ut. Debitis nulla cumque veritatis. Sunt suscipit voluptas ipsa in tempora esse soluta sint donec adipiscing..", "title":"UX Research", "icon":"#assetPath#images/icons/services/icon-research.svg"},
               {"text":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Venenatis lectus magna fringilla urna. Lectus vestibulum mattis ullamcorper velit sed ullamcorper morbi. Sit amet aliquam.", "title":"Illustration", "icon":"#assetPath#images/icons/services/icon-illustration.svg"},
                   {"text":"Nullam eget felis eget nunc. Adipiscing commodo elit at imperdiet dui accumsan. Condimentum mattis pellentesque id nibh tortor id aliquet lectus proin. Orci eu lobortis elementum nibh tellus. Tortor vitae purus faucibus ornare suspendisse.", "title":"E-Commerce", "icon":"#assetPath#images/icons/services/icon-ecommerce.svg"},
                   {"text":"Nemo cupiditate ab quibusdam quaerat impedit magni. Earum suscipit ipsum laudantium. Quo delectus est. Maiores voluptas ab sit natus veritatis ut. Debitis nulla cumque veritatis. Sunt suscipit voluptas ipsa in tempora esse soluta sint aliquam rhoncus elit.", "title":"Product Design", "icon":"#assetPath#images/icons/services/icon-product-design.svg"},
            {"text":"Nulla pharetra diam sit amet nisl suscipit adipiscing bibendum est. Quis risus sed vulputate odio ut. Lectus arcu bibendum at varius vel. Lorem ipsum dolor sit amet consectetur adipiscing elit pellentesque. In nulla posuere sollicitudin aliquam ultrices.", "title":"Branding", "icon":"#assetPath#images/icons/services/icon-branding.svg"}
            ],"title":"We’ve got everything you
need to launch and grow
your business", "subtitle":"What We Do"},"id":"features","active":"1"},


            {"values":{"text":"Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quis rem, esse doloribus sint eaque at debitis enim vitae minus expedita ratione dignissimos sit nostrum optio sequi. Ipsa at beatae quam.","button-url":"##","title":"Get started with a consultation today.","button-label":"Let''s Work Together"},"id":"call-to-action","active":"1"}]'
        };

        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), { 'key' = 'image',
            name = 'Featured Image', value = '' });

        admin.setPageCustomField( result.newPage.getId(), customFields );

        var parent = result.newPage.getId();


        admin.removeSetting( 'site/info', 'logo' );
        admin.removeSetting( 'site/info', 'newsletter-enabled' );
        admin.removeSetting( 'site/info', 'newsletter-intro' );

        var b = admin.getBlog().clone();

        admin.editBlog( b.getTitle(), "Some good tagline",  "Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptas illum quasi facere libero.", b.getUrl(), 'tyndale' );

        return result;
    }
}