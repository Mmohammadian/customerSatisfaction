create or replace function fnc_get_fqs_data(p_app_id number)
return clob
as 
    cursor c_fqs is
        select  fqs.id, fqs.question
        from    tb_feedback_question fqs
        where   fqs.fk_flk_fqs_type = 1
        and     fqs.is_active = 1
        and     (trunc(fqs.deactive_date) >= trunc(sysdate) or fqs.deactive_date is null)
        and     fqs.APP_ID = p_app_id;
        
    cursor c_opt(p_fk_fqs number) is
        select  opt.id, opt.answer
        from    tb_feedback_options opt
        where   fk_fqs = p_fk_fqs
        and     void_date is null;
    v_result_json clob;
begin
    apex_json.initialize_clob_output;
    apex_json.open_array;
    for i in c_fqs loop
        apex_json.open_object;
        apex_json.write('fqs_id', i.id);
        apex_json.write('fqs_question', i.question);
        apex_json.open_array('options');
        for j in c_opt(i.id) loop
            apex_json.open_object;
            apex_json.write('opt_id', j.id);
            apex_json.write('opt_answer', j.answer);
            apex_json.close_object;
        end loop;
        apex_json.close_array;
        apex_json.close_object;
    end loop;
    apex_json.close_array;
    v_result_json := apex_json.get_clob_output;
    apex_json.free_output;
    return v_result_json;
exception
    when others then
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.write('status', 'error');
        apex_json.write('message', 'خطا در دریافت سوالات: ' || sqlerrm);
        apex_json.close_object;
        v_result_json := apex_json.get_clob_output;
        apex_json.free_output;
end;
/