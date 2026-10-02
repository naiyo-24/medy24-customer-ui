import sys
import glob

def fix_file(filename):
    with open(filename, "r") as f:
        content = f.read()

    # We want to populate controllers in build if it's the first time we get data
    # Let's add a boolean flag
    new_init = """  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();"""
    
    if "bool _isInitialized" not in content:
        content = content.replace("  @override\n  void initState() {\n    super.initState();", new_init)
        
        # Remove the old addPostFrameCallback
        content = content.split("WidgetsBinding.instance.addPostFrameCallback")[0] + "  }\n\n  @override\n  void dispose() {" + content.split("  void dispose() {")[1]
        
        # Add the population logic to build
        if "location_screen" in filename:
            build_logic = """  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopProfileProvider);
    shopAsync.whenData((shopData) {
      if (!_isInitialized && shopData != null) {
        _addressCtrl.text = shopData['address'] ?? '';
        _gstinCtrl.text = shopData['gstinNo'] ?? '';
        _isInitialized = true;
      }
    });

    return Scaffold("""
        elif "bank_details_screen" in filename:
            build_logic = """  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopProfileProvider);
    shopAsync.whenData((shopData) {
      if (!_isInitialized && shopData != null) {
        _bankNameCtrl.text = shopData['bankName'] ?? '';
        _bankAccountCtrl.text = shopData['bankAccountNo'] ?? '';
        _bankIfscCtrl.text = shopData['bankIfscCode'] ?? '';
        _isInitialized = true;
      }
    });

    return Scaffold("""
        else:
            build_logic = "  @override\n  Widget build(BuildContext context) {\n    return Scaffold("
            
        content = content.replace("  @override\n  Widget build(BuildContext context) {\n    return Scaffold(", build_logic)
        
        with open(filename, "w") as f:
            f.write(content)
        print(f"Fixed {filename}")

fix_file("/Users/hypothticoder/medy24-customer-ui/lib/screens/retailer_dashboard/profile/retailer_location_screen.dart")
fix_file("/Users/hypothticoder/medy24-customer-ui/lib/screens/retailer_dashboard/profile/retailer_bank_details_screen.dart")
