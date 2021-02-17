define([
    'jquery'], function ($) {

    return {
        /**
         * Do get ajax
         * @param url : endpoint
         * @param parameters : parameters of request
         * @param headers : headers of request
         * @returns {*|jQuery|*|*|*|*}
         */
        get: function (url, parameters, headers) {
            /** GET Request that receive url and handle callback **/
            return $.ajax({
                url: url,
                data: parameters,
                dataType: 'json',
                beforeSend: function (xhrObj) {
                    if (headers) {
                        $.each(headers, function (key, value) {
                            xhrObj.setRequestHeader(key, value);
                        });
                    }
                }
            });
        },
        /**
         * Do ajax post
         * @param url : endpoint
         * @param data : data that will be pushed
         * @param contentType : content type of data
         * @returns {*|jQuery|*|*|*|*}
         */
        post: function (url, data, contentType) {
            /** GET Request that receive url and handle callback **/
            if (contentType === 'application/json') {
                data = JSON.stringify(data)
            }
            return $.ajax({
                url: url,
                data: data,
                contentType: contentType || 'application/x-www-form-urlencoded; charset=UTF-8',
                type: 'POST'
            });
        },
        /**
         * Do delete ajax
         * @param url : endpoint
         * @param parameters : parameters of request
         * @returns {*|jQuery|*|*|*|*}
         */
        delete: function (url, parameters) {
            /** GET Request that receive url and handle callback **/
            return $.ajax({
                url: url,
                data: parameters,
                dataType: 'json',
                type: 'DELETE'
            });
        }
    }
});

