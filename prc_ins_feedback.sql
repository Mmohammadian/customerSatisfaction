create or replace procedure prc_ins_feedback(
    p_json     clob,
    p_app_id   number default null,
    p_page_id  number default null,
    p_user_id  number,
    p_out_result out varchar2
)
as
    l_rating        number;    
    l_fqs_id        number;
    l_reasons       apex_t_varchar2;
    l_extra         varchar2(4000 char);
    l_flowId        number;
    l_flowStepId    number;
    v_valid_count   number := 0;
    l_feedback_id   number;
begin
    if p_json is not null then
        apex_json.parse(p_json);
        l_rating     := apex_json.get_number('rating');
        l_fqs_id     := apex_json.get_number('fqs_id');
        l_reasons    := apex_string.split(apex_json.get_varchar2('reasons'), ',');
        l_extra      := apex_json.get_varchar2('extra');
        l_flowId     := apex_json.get_number('flowId');
        l_flowStepId := apex_json.get_number('flowStepId');

        select count(id)
          into v_valid_count
          from tb_feedback
         where app_id      = to_number(nvl(p_app_id, l_flowId))
           and page_id     = to_number(nvl(p_page_id, l_flowStepId))
           and fk_user_fed = p_user_id;

        if v_valid_count >= 3 then
            apex_json.initialize_clob_output;
            apex_json.open_object;
            apex_json.write('status', 'err_count');
            apex_json.write('message','تعداد مجاز ثبت بازخورد شما برای این صفحه به پایان رسیده است.');
            apex_json.close_object;
            htp.p(apex_json.get_clob_output);
            apex_json.free_output;
            return;
        end if;

        insert into tb_feedback (
            rating,
            description,
            fk_fqs,
            app_id,
            page_id,
            fk_user_fed
        ) values (
            to_number(l_rating),
            apex_escape.html(l_extra),
            to_number(l_fqs_id),
            to_number(nvl(p_app_Id, l_flowId)),
            to_number(nvl(p_page_Id, l_flowStepId)),
            to_number(p_user_id)
        )
        returning id into l_feedback_id;

        if l_reasons is not null and l_reasons.count > 0 then
            for i in 1..l_reasons.count loop
                if l_reasons(i) is not null then
                    insert into tb_feedback_detail (
                        fk_fed,
                        fk_opt
                    ) values (
                        l_feedback_id,
                        to_number(l_reasons(i))
                    );
                end if;
            end loop;
        end if;
    end if;

    apex_json.initialize_clob_output;
    apex_json.open_object;
    apex_json.write('status', 'success');
    apex_json.write('message', 'بازخورد با موفقیت ثبت شد.');
    apex_json.write('feedback_id', l_feedback_id); 
    apex_json.close_object;
    p_out_result := apex_json.get_clob_output;
    apex_json.free_output;

exception
    when others then
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.write('status', 'error');
        apex_json.write('message', sqlerrm);
        apex_json.close_object;
        p_out_result := apex_json.get_clob_output ;
        apex_json.free_output;
end;
/
