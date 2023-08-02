$(() => {

    $('body').hide();

    window.addEventListener('message', function(event) {
        const {action, type, characters, can_add} = event.data;
        
        if(type == undefined){
            if(action == 'open:multicharacter'){
                $('.multicharacter-loading').fadeOut(250)
                buildCharactersData(characters, can_add)
            }else{
                $('body').fadeOut(500);  
            };
        }else if(type == 'loading:multicharacter'){
            $('body').show();
            $('.multicharacter-info').hide();
            $('.multicharacter-selection').hide();
            $('.multicharacter-container').hide();
            $('.multicharacter-loading').fadeIn(250)
        };
    })

    const buildCharactersData = (data, can_add) => {
        $('body').show();
        $('.multicharacter-container').show();
        $('.multicharacter-container').removeClass('hide').addClass('show');

        $('.multicharacter-info').hide();
        $('.multicharacter-selection').hide();

        $('.multicharacter-slots').empty()

        data.forEach(data => {
            $('.multicharacter-slots').append(`
                <div class="item-slot" id="user-${data.id}" data-id="${data.id}">
                    <i class="fa-solid fa-user"></i>
                    <div class="info-slot">
                        <div class="info-name">Nombre : <span>${data.firstname} ${data.lastname}</span></div>
                        <div class="info-id">ID : <span>${data.id}</span></div>
                    </div>
                </div>
            `);

            $(`#user-${data.id}`).click(() => {

                $('.options').empty()

                $('.multicharacter-container').removeClass('show').addClass('hide');

                post('select_character', {
                    id : data.id
                });

                setTimeout(function(){
                    showAllCharacterInfo(data)
                    $('.multicharacter-container').hide();

                    $('.options').empty()

                    $('.options').append(`
                        <div class="options-close">cerrar</div>
                        <div class="options-play" id="play-${data.id}">entrar</div>
                    `);

                    $('.multicharacter-info').show();
                    $('.multicharacter-selection').show();

                    $(`#play-${data.id}`).click(() => {
                        post('enter_game', {
                            id : data.id
                        });
                    })
        
                    $('.options-close').click(() => {
                        $('.multicharacter-container').show();
                        $('.multicharacter-container').removeClass('hide').addClass('show');
                
                        $('.multicharacter-info').fadeOut(250);
                        $('.multicharacter-selection').fadeOut(250);
                    });
                }, 500);
            });
        });

        $('.multicharacter-add').click(() => {
            post('new_character')
        });

        if(can_add){
            $('.multicharacter-add').css({
                'pointer-events' : 'auto',
                'opacity' : '1'
            })
        }else{
            $('.multicharacter-add').css({
                'pointer-events' : 'none',
                'opacity' : '.4'
            })
        };
    };

    const showAllCharacterInfo = (data) => {
      
        const {firstname, lastname, bank, sex, dateofbirth, job, job_grade, money} = data;
        
        $('#name').text('Nombre : ' + firstname + ' ' + lastname)
        $('#bank').text('Banco : ' + bank + ' $')
        $('#money').text('Efectivo : ' + money + ' $')
        $('#dateofbirth').text('Nacimiento : ' + dateofbirth)
        $('#job').text('Oficio : ' + job)
        $('#sex').text('Genero : ' + sex)

    };
})
