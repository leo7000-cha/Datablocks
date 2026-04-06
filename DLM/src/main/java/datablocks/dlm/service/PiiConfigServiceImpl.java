package datablocks.dlm.service;

import datablocks.dlm.config.EnvConfig;
import datablocks.dlm.domain.Criteria;
import datablocks.dlm.domain.PiiConfigVO;
import datablocks.dlm.mapper.PiiConfigMapper;
import datablocks.dlm.util.LogUtil;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;


@Service
@AllArgsConstructor
public class PiiConfigServiceImpl implements PiiConfigService {
	private static final Logger logger = LoggerFactory.getLogger(PiiConfigServiceImpl.class);
	@Autowired
	private PiiConfigMapper mapper;

	@Autowired
	private ArchiveNamingService archiveNamingService;

	@Override
	public List<PiiConfigVO> getList() {
		
		LogUtil.log("INFO", "get List: " );

		return mapper.getList();
	}
	
	@Override
	public List<PiiConfigVO> getList(Criteria cri) {
		
		LogUtil.log("INFO", "get List with criteria: " + cri);
		
		return mapper.getListWithPaging(cri);
	}

	@Override
	public void register(PiiConfigVO config) {
		
		 LogUtil.log("INFO", "register......" + config);
		 
		 mapper.insert(config);
		 refreshConfig();
	}
		 
	@Override
	public boolean remove(String cfgkey) {

		LogUtil.log("INFO", "remove...." + cfgkey);

		// 삭제 전 확인
		PiiConfigVO before = mapper.read(cfgkey);
		logger.warn("DELETE BEFORE: cfgkey={}, exists={}", cfgkey, (before != null));

		int rstcnt = mapper.delete(cfgkey);
		logger.warn("DELETE RESULT: cfgkey={}, deletedRows={}", cfgkey, rstcnt);

		// 삭제 후 확인
		PiiConfigVO after = mapper.read(cfgkey);
		logger.warn("DELETE AFTER: cfgkey={}, stillExists={}", cfgkey, (after != null));

		refreshConfig();
		return  rstcnt == 1;
	}

	@Override
	public int getTotal(Criteria cri) {
		
		LogUtil.log("INFO", "get total count");
		return mapper.getTotalCount(cri);
	}

	@Override
	public PiiConfigVO get(String cfgkey) {
		
		 LogUtil.log("INFO", "get......" + cfgkey);
		 
		 return mapper.read(cfgkey);
	}

	@Override
	public boolean modify(PiiConfigVO config) {
		
		LogUtil.log("INFO", "modify......" + config);
		int rstcnt = mapper.update(config);
		refreshConfig();
		return rstcnt == 1;
	}

	@Override
	public boolean modifyVal(String cfgkey, String value) {

		LogUtil.log("INFO", "modifyVal......" + cfgkey +" "+value);
		int rstcnt = mapper.updateVal(cfgkey, value);
		refreshConfig();
		return rstcnt == 1;
	}

	@Override
	public boolean refreshConfig() {

		try {
			List<PiiConfigVO> configList = mapper.getList();

			for (PiiConfigVO config : configList) {
				String key = config.getCfgkey();
				String value = config.getValue();
				EnvConfig.setConfig(key, value);
				logger.warn("info$ "+"Initialized config: {} = {}", key, value);
			}

			// ArchiveNamingService 캐시도 갱신
			archiveNamingService.refreshConfig();
			logger.info("ArchiveNamingService config refreshed");

			//logger.warn("warn "+"successfully initialize code: " + EnvConfig.getConfig("SITE"));
		} catch (Exception e) {
			logger.warn("warn "+"Failed to initialize code: " + e.getMessage());
			// 여기에 적절한 에러 처리 로직 추가
		}

		return true;
	}

}
