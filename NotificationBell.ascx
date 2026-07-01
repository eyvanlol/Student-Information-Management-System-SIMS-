<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NotificationBell.ascx.cs" Inherits="StudentManagementSystem.NotificationBell" %>

<style>
    /* ---- YouTube-style notification bell + dropdown (scoped: .sims-notif-*) ---- */
    .sims-notif-wrap { position: relative; }
    .sims-notif-panel {
        position: absolute; top: 52px; right: 0; width: 360px; max-width: 92vw;
        background: #fff; border: 1px solid #e5e7eb; border-radius: 12px;
        box-shadow: 0 12px 32px rgba(0,0,0,0.18); z-index: 1050;
        opacity: 0; visibility: hidden; transform: translateY(-8px);
        transition: opacity .15s ease, transform .15s ease, visibility .15s;
        overflow: hidden; cursor: default; text-align: left;
    }
    .sims-notif-panel.open { opacity: 1; visibility: visible; transform: translateY(0); }
    .sims-notif-panel::before {
        content: ""; position: absolute; top: -7px; right: 14px; width: 12px; height: 12px;
        background: #fff; border-left: 1px solid #e5e7eb; border-top: 1px solid #e5e7eb;
        transform: rotate(45deg);
    }
    .sims-notif-head {
        display: flex; align-items: center; justify-content: space-between;
        padding: 13px 16px; border-bottom: 1px solid #f0f0f0;
    }
    .sims-notif-head > span:first-child { font-weight: 700; font-size: 0.95rem; color: #1f2937; }
    .sims-notif-count { font-size: 0.72rem; font-weight: 600; color: #fff; background: #e74c3c;
        padding: 2px 9px; border-radius: 10px; }
    .sims-notif-body { max-height: 380px; overflow-y: auto; }
    .sims-notif-item {
        display: flex; gap: 11px; padding: 12px 16px; border-bottom: 1px solid #f5f5f5;
        text-decoration: none; transition: background .12s;
    }
    .sims-notif-item:hover { background: #f8f9fb; }
    .sims-notif-dot { flex: 0 0 9px; width: 9px; height: 9px; border-radius: 50%; margin-top: 5px; }
    .sims-notif-text { display: flex; flex-direction: column; min-width: 0; }
    .sims-notif-title { font-size: 0.86rem; font-weight: 600; color: #1f2937; line-height: 1.25; }
    .sims-notif-msg { font-size: 0.8rem; color: #6b7280; line-height: 1.3; margin-top: 2px;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .sims-notif-time { font-size: 0.72rem; color: #9ca3af; margin-top: 4px; }
    .sims-notif-empty { padding: 34px 16px; text-align: center; color: #9ca3af; }
    .sims-notif-empty i { font-size: 1.6rem; display: block; margin-bottom: 8px; opacity: .6; }
    .sims-notif-empty div { font-size: 0.85rem; }
    .sims-notif-foot {
        display: block; text-align: center; padding: 11px; font-size: 0.83rem; font-weight: 600;
        color: #2563eb; text-decoration: none; border-top: 1px solid #f0f0f0; background: #fafafa;
    }
    .sims-notif-foot:hover { background: #f1f3f9; color: #1d4ed8; }
</style>

<div class="notification-bell sims-notif-wrap" id="simsNotifWrap" title="View notifications">
    <i class="fas fa-bell text-muted" style="cursor:pointer;" onclick="simsNotifToggle(event)"></i>
    <asp:Label ID="lblBadge" runat="server" CssClass="badge" Visible="false" />

    <div class="sims-notif-panel" id="simsNotifPanel">
        <div class="sims-notif-head">
            <span>Notifications</span>
            <asp:Label ID="lblHeadCount" runat="server" CssClass="sims-notif-count" Visible="false" />
        </div>
        <div class="sims-notif-body">
            <asp:Repeater ID="rptNotif" runat="server">
                <ItemTemplate>
                    <div class="sims-notif-item">
                        <span class="sims-notif-dot" style='background: <%# Dot(Eval("notifType")) %>;'></span>
                        <span class="sims-notif-text">
                            <span class="sims-notif-title"><%# Enc(Eval("title")) %></span>
                            <span class="sims-notif-msg"><%# Snippet(Eval("message")) %></span>
                            <span class="sims-notif-time"><%# Ago(Eval("createdAt")) %></span>
                        </span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlEmpty" runat="server" CssClass="sims-notif-empty" Visible="false">
                <i class="fas fa-bell-slash"></i>
                <div>You're all caught up</div>
            </asp:Panel>
        </div>
        <a id="simsNotifSeeAll" runat="server" class="sims-notif-foot">See all notifications</a>
    </div>
</div>

<script>
    (function () {
        function toggle(e) {
            if (e) { e.stopPropagation(); }
            var p = document.getElementById('simsNotifPanel');
            if (p) { p.classList.toggle('open'); }
        }
        window.simsNotifToggle = toggle;
        document.addEventListener('click', function (e) {
            var wrap = document.getElementById('simsNotifWrap');
            var panel = document.getElementById('simsNotifPanel');
            if (panel && wrap && !wrap.contains(e.target)) { panel.classList.remove('open'); }
        });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                var panel = document.getElementById('simsNotifPanel');
                if (panel) { panel.classList.remove('open'); }
            }
        });
    })();
</script>
