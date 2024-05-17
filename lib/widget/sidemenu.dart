import 'package:dtlive/model/sectiontypemodel.dart';
import 'package:dtlive/pages/home.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/profileprovider.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/focusbase.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/widget/myusernetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late ProfileProvider profileProvider;
  late HomeProvider homeProvider;
  late SectionDataProvider sectionDataProvider;

  @override
  void initState() {
    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    getData();
    super.initState();
  }

  getData() async {
    debugPrint("userID ===========> ${Constant.userID}");
    if (Constant.userID != null) {
      await profileProvider.getProfile();
    }
    Future.delayed(Duration.zero).then((value) {
      setState(() {
        widget._controller.setExtended(true);
      });
    });
  }

  Future<void> getTabData(int position) async {
    debugPrint("getTabData position ======> $position");
    debugPrint(
        "getTabData lastTabPos ====> ${sectionDataProvider.lastTabPosition}");
    if (!mounted) return;
    await homeProvider.setSelectedTab(position);
    if (sectionDataProvider.lastTabPosition == position) {
      return;
    }
    sectionDataProvider.setTabPosition(position);
    await sectionDataProvider.setLoading(true);
    await sectionDataProvider.getSectionBanner(
        position == 0
            ? "0"
            : (homeProvider.sectionTypeModel.result?[position - 1].id),
        position == 0 ? "1" : "2");
    await sectionDataProvider.getSectionList(
        position == 0
            ? "0"
            : (homeProvider.sectionTypeModel.result?[position - 1].id),
        position == 0 ? "1" : "2");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return SidebarX(
          showToggleButton: false,
          controller: widget._controller,
          theme: SidebarXTheme(
            width: Dimens.widthSideMenu,
            decoration: BoxDecoration(
              color: appBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            hoverColor: blackTrans50,
            itemMargin: EdgeInsets.zero,
            itemPadding: EdgeInsets.zero,
            itemTextPadding: EdgeInsets.zero,
            selectedItemMargin: EdgeInsets.zero,
            selectedItemTextPadding: EdgeInsets.zero,
            selectedItemPadding: EdgeInsets.zero,
          ),
          extendedTheme: SidebarXTheme(
            width: Dimens.widthSideMenu,
            decoration: BoxDecoration(
              color: appBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            hoverColor: blackTrans50,
            itemMargin: EdgeInsets.zero,
            itemPadding: EdgeInsets.zero,
            itemTextPadding: EdgeInsets.zero,
            selectedItemMargin: EdgeInsets.zero,
            selectedItemTextPadding: EdgeInsets.zero,
            selectedItemPadding: EdgeInsets.zero,
          ),
          headerBuilder: (context, extended) {
            return _buildHeader(extended);
          },
          items: List<SidebarXItem>.generate(
            (homeProvider.sectionTypeModel.result?.length ?? 0) + 1,
            (index) {
              return _buildNavigation(
                index: index,
                sectionTypeList: homeProvider.sectionTypeModel.result,
              );
            },
          ),
        );
      },
    );
  }

  SidebarXItem _buildNavigation({
    required int index,
    required List<Result>? sectionTypeList,
  }) {
    return SidebarXItem(
      label: '',
      iconWidget: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints(minWidth: Dimens.widthSideMenu),
        child: FocusBase(
          focusColor: gray.withOpacity(0.5),
          onFocus: (isFocused) async {
            debugPrint("Type isFocused ===========> $isFocused");
            homeProvider.setFocused(isFocused);
            if (isFocused) {
              debugPrint("Type index ===========> $index");
            } else {}
          },
          onPressed: () async {
            debugPrint("Type index ===========> $index");
            debugPrint("Type (index - 1) =====> ${(index - 1)}");
            replaceByName(
                index == 0
                    ? ""
                    : (sectionTypeList?[index - 1].name.toString() ?? ""),
                index);
          },
          child: Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return Container(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                constraints: const BoxConstraints(maxHeight: 30),
                alignment: Alignment.center,
                child: MyText(
                  color: white,
                  multilanguage: false,
                  text: index == 0
                      ? "Home"
                      : index > 0
                          ? (sectionTypeList?[index - 1].name.toString() ?? "")
                          : "",
                  fontsizeNormal: 12,
                  fontweight: FontWeight.w700,
                  fontsizeWeb: 14,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  SidebarXItem buildFooterItem({
    required int index,
    required String title,
  }) {
    return SidebarXItem(
      iconWidget: Container(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        alignment: Alignment.center,
        child: FocusBase(
          focusColor: gray.withOpacity(0.5),
          onFocus: (isFocused) {
            Utils.setSidebarToggle(widget._controller, isFocused);
          },
          onPressed: () {
            // replaceByName(title);
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 20),
            alignment: Alignment.center,
            child: MyText(
              color: white,
              multilanguage: true,
              text: title,
              fontsizeNormal: 12,
              fontweight: FontWeight.w700,
              fontsizeWeb: 14,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }

  replaceByName(String name, int index) async {
    switch (name) {
      case 'Channels':
        widget._controller.selectIndex(6);
        break;
      case 'Store':
        widget._controller.selectIndex(7);
        break;
      case 'Logout':
        await Utils.setUserId(null);
        await homeProvider.updateSideMenu();
        await profileProvider.clearProvider();
        getData();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const Home(pageName: '')),
          (Route<dynamic> route) => false,
        );
        break;
      case 'Subscription':
        Utils.openSubscription(
            context: context, controller: widget._controller);
        break;
      case 'Language':
        widget._controller.selectIndex(8);
        break;
      case 'Login':
        Utils.openLogin(context: context, controller: widget._controller);
        break;
      default:
        widget._controller.selectIndex(0);
        getTabData(index);
        break;
    }
  }

  Widget _buildHeader(bool isExpand) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          height: 50,
          width: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: FocusBase(
              focusColor: white,
              onFocus: (isFocused) {},
              onPressed: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyUserNetworkImage(
                  imageUrl: profileProvider.profileModel.status == 200
                      ? profileProvider.profileModel.result != null
                          ? (profileProvider.profileModel.result?[0].image ??
                              "")
                          : ""
                      : "",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  final divider = Divider(color: white.withOpacity(0.3), height: 1);
}
