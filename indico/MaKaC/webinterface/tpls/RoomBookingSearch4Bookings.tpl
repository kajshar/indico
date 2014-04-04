<script type="text/javascript">

    function adjustDates(s, e) {
        if (s.datepicker('getDate') > e.datepicker('getDate'))
            e.datepicker('setDate', s.datepicker('getDate'));
    }

    function initWidgets() {
        $('#timerange').timerange();

        var s = $('#start_date'), e = $('#end_date');
        $('#start_date, #end_date').datepicker({
            onSelect: function() {
                adjustDates(s, e);
                $('searchForm').trigger('change');
            }
        });
        s.datepicker('setDate', '+0');
        e.datepicker('setDate', '+7');
    }

    function confirm_search() {
        if ($('#is_only_mine').is(':checked') || $('#roomIDList').val() !== null) {
            return true;
        }
        try { if ($('#is_only_my_rooms').is(':checked')) { return true; } } catch (err) {}
        new AlertPopup($T('Select room'), $T('Please select a room (or several rooms).')).open();
        return false;
    }

    // Reads out the invalid textboxes and returns false if something is invalid.
    // Returns true if form may be submited.
    function forms_are_valid(onSubmit) {
        if (onSubmit != true) {
            onSubmit = false;
        }

        // Clean up - make all textboxes white again
        var searchForm = $('#searchForm');
        $(':input', searchForm).removeClass('invalid');

        // Init
        var isValid = true;

        // Datepicker
        if (!is_date_valid($('#start_date').val())) {
            isValid = false;
            $('#start_date').addClass('invalid');
        }
        if (!is_date_valid($('#end_date').val())) {
            isValid = false;
            $('#end_date').addClass('invalid');
        }

        // Time period
        isValid = isValid && $('#timerange').timerange('validate');

        // Holidays warning
        if (isValid && !onSubmit) {
            var lastDateInfo = searchForm.data('lastDateInfo');
            var dateInfo = $('#start_date, #sTime, #end_date, #eTime').serialize();
            if (dateInfo != lastDateInfo) {
                searchForm.data('lastDateInfo', dateInfo);
                var holidaysWarning = indicoSource(
                    'roomBooking.getDateWarning', searchForm.serializeObject()
                );

                holidaysWarning.state.observe(function(state) {
                    if (state == SourceState.Loaded) {
                        $E('holidays-warning').set(holidaysWarning.get());
                    }
                });
            }
        }
        return isValid;
    }

    $(function() {
        initWidgets();

        $('#is_only_bookings').change(function() {
            if(this.checked) {
                $('#is_only_pre_bookings').prop('checked', false);
            }
        });

        $('#is_only_pre_bookings').change(function() {
            if(this.checked) {
                $('#is_only_bookings').prop('checked', false);
            }
        });

        $('#searchForm').delegate(':input', 'keyup change', function() {
            forms_are_valid();
        }).submit(function(e) {
            if (!forms_are_valid(true)) {
                new AlertPopup($T('Error'), $T('There are errors in the form. Please correct fields with red background.')).open();
                e.preventDefault();
            }
            else if(!confirm_search()) {
                e.preventDefault();
            }
            else {
                $('#start_date').val($('#start_date').val() + ' ' + $('#sTime').val());
                $('#end_date').val($('#end_date').val() + ' ' + $('#eTime').val());
            }
        });
    });
</script>

<!-- CONTEXT HELP DIVS -->
<div id="tooltipPool" style="display: none">
  <!-- Choose Button -->
  <div id="chooseButtonHelp" class="tip">
    ${ _('Directly choose the room.') }
  </div>
</div>
<!-- END OF CONTEXT HELP DIVS -->

<h2 class="page-title">
    ${ _('Search bookings') }
</h2>

<form id="searchForm" method="post" action="${ roomBookingBookingListURL }">
    <h2 class="group-title">
        <i class="icon-location"></i>
        ${ _('Rooms') }
    </h2>

    <select name="room_id_list" id="roomIDList" multiple="multiple" size="8">
        <option value="-1">${ _('All Rooms') }</option>
        % for room in rooms:
            <option value="${ room.id }" class="${ room.kind }">
              ${ room.location.name }&nbsp;${ room.getFullName() }
            </option>
        % endfor
    </select>
    <input type="hidden" name="is_search" value="y"/>
    <i class="icon-question" title="${ _('You can select multiple rooms the same way you select multiple files in Windows - press (and hold) left mouse button and move the cursor. Alternatively you can use keyboard - hold SHIFT and press up/down arrows.') }"></i>

    <h2 class="group-title">
        <i class="icon-time"></i>
        ${ _('Timespan') }
    </h2>

    <div class="toolbar thin">
        <div class="group with-datepicker">
            <span class="i-button label heavy">
                ${ _('Start Date') }
            </span>
            <span class="datepicker thin">
                <input type="text" name="start_date" id="start_date"/>
            </span>
        </div>

        <div class="group with-datepicker">
            <span class="i-button label heavy">
                ${ _('End Date') }
            </span>
            <span class="datepicker thin">
                <input type="text" name="end_date" id="end_date"/>
            </span>
        </div>
    </div>

    <div id="timerange"></div>

    <h2 class="group-title">
        <i class="icon-info"></i>
        ${ _('Details') }
    </h2>

    <div class="toolbar thin">
        <div class="group">
            <div class="i-button label heavy">Booked for</div>
            <input size="30" type="text" id="booked_for_name" name="booked_for_name" />
        </div>
    </div>
    <div class="toolbar thin">
        <div class="group">
            <div class="i-button label heavy">Reason</div>
            <input size="30" type="text" id="reason" name="reason" />
        </div>
    </div>

    <input id="submitBtn1" type="submit" class="i-button highlight" value="${ _('Search') }"/>

    <h2 class="group-title">
        ${ _('Advanced search') }
    </h2>
    <table width="100%" align="center" cellpadding="0" cellspacing="0" border="0">
        <tr>
            <td align="right">
                <table width="100%" cellspacing="4px">
                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-space: nowrap">
                            <small>${ _('Only Bookings') } &nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext" >
                            <input id="is_only_bookings" name="is_only_bookings" type="checkbox" />
                            ${ inlineContextHelp( _('Show only <b>Bookings</b>. If not checked, both pre-bookings and confirmed bookings will be shown.')) }
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-  space: nowrap">
                            <small>${ _('Only Pre-bookings') }&nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext">
                            <input id="is_only_pre_bookings" name="is_only_pre_bookings" type="checkbox" />
                            ${ inlineContextHelp( _('Show only <b>PRE-bookings</b>. If not checked, both pre-bookings and confirmed bookings will be shown.')  ) }
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-  space: nowrap">
                            <small>${ _('Only mine') }&nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext" >
                            <input id="is_only_mine" name="is_only_mine" type="checkbox" />
                            ${ inlineContextHelp(_('Show only <b>your</b> bookings.')) }
                            <br/>
                        </td>
                    </tr>

                    % if isResponsibleForRooms:
                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-  space: nowrap">
                            <small>${ _('Of my rooms') }&nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext">
                            <input id="is_only_my_rooms" name="is_only_my_rooms" type="checkbox" />
                            ${ inlineContextHelp(_('Only bookings of rooms you are responsible for.')) }
                            <br/>
                        </td>
                    </tr>
                    % endif

                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-  space: nowrap">
                            <small>${ _('Is rejected') }&nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext" >
                            <input id="is_rejected" name="is_rejected" type="checkbox" />
                        </td>
                    </tr>
                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-  space: nowrap">
                            <small>${ _('Is cancelled') }&nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext">
                            <input id="is_cancelled" name="is_cancelled" type="checkbox" />
                        </td>
                    </tr>
                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-  space: nowrap">
                            <small>${ _('Is archival') }&nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext" >
                            <input id="is_archival" name="is_archival" type="checkbox" />
                        </td>
                    </tr>
                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-  space: nowrap">
                            <small>${ _('Uses video-conf.') }&nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext" >
                            <input id="uses_video_conference" name="uses_video_conference" type="checkbox" />
                            ${ inlineContextHelp(_('Show only bookings which will use video   conferencing systems.')) }
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-  space: nowrap">
                            <small>${ _('Assistance for video-conf. startup') }&nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext" >
                            <input id="needs_video_conference_setup" name="needs_video_conference_setup" type="checkbox" />
                            ${ inlineContextHelp(_('Show only bookings which requested assistance   for the startup of the videoconference session.')) }
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-  space: nowrap">
                            <small>${ _('Assistance for meeting startup') }&nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext" >
                            <input id="needs_general_assistance" name="needs_general_assistance" type="checkbox" />
                            ${ inlineContextHelp(_('Show only bookings which requested assistance   for the startup of the meeting.')) }
                            <br />
                        </td>
                    </tr>
                    <tr>
                        <td style="width:165px; text-align: right; vertical-align: top; white-space: nowrap">
                            <small>${ _('Is heavy') }&nbsp;&nbsp;</small>
                        </td>
                        <td align="left" class="blacktext" >
                            <input id="is_heavy" name="is_heavy" type="checkbox" />
                            ${ inlineContextHelp(_('Show only <b>heavy</b> bookings.')) }
                            <br />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</form>
