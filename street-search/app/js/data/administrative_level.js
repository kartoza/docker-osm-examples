define([], function () {
    const mapping = {
        'South Africa': {
            2: 'Country',
            4: 'Region',
            6: 'Settlement',
        },
        'الأردن': {
            2: 'Country',
            4: 'Governorate',
            6: 'District',
            7: 'Subdistrict',
        }
    }
    return {
        map: function (data) {
            try {
                let country = data[data.length - 1].name;
                const adm = mapping[country];
                $.each(data, function (key, value) {
                    if (adm[value.level]) {
                        value.level = adm[value.level];
                    }
                });
            } catch (e) {

            }
            return data;
        }
    }
});

